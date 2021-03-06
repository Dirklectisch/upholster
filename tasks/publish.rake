require 'rake'
require 'rake/clean'

CLOBBER.include File.join('source', '_rev.txt')

desc "Open CouchDB design doc method in a browser"
task :open, [:path] => 'config/database.yml' do |t, args|

    require 'upholster'
        
    sh "open #{Upholster.resolve_path(args.path)}"

end

task :publish, [:database] => 'source.json' do |t, args|

    require 'rufus-verbs'
    require 'upholster'
    include Rufus::Verbs

    args.with_defaults :database => CONFIG[:database][:default]
    design_doc = File.join(args.database, Upholster.resolve_design_path)

    resource args.database do |rt|
        puts "Creating database #{rt.name}"
        resp = put(rt.name)
        if resp.code.to_i == 201
            puts "Database #{rt.name} Created"
        else
            puts "Database not created. (Error Code: #{resp.code.to_i})"
        end
    end

    file 'source/_rev' => args.database do |ft|
        puts "Updating document revision (#{ft.name})"
        resp = head(design_doc)
        case resp.code.to_i
        when 200      
            _rev = resp.header['Etag']
            File.open(File.join('source', '_rev.txt'), 'w'){|f| f.write _rev.match(/\d+-\w+/)}
            puts "Revision updated (_rev: #{_rev})"
        when 404
            puts "Remote document not found, removing local revision number"
            if File.exist?(File.join('source', '_rev.txt'))
                File.delete(File.join('source', '_rev.txt'))
            end
        else
            puts "Could not determine remote revision"
        end
    end

    resource design_doc => ['source.json', args.database] do |rt|
        puts "Updating design document #{rt.name}"
        resp = put(rt.name) do |request|
            request['content-type'] = 'application/json'
            File.read('source.json')
        end
        case resp.code.to_i
        when 201
            puts "Design document updated"
            Rake::Task['source/_rev'].invoke
        when 409
            puts "Document update conflict"
            Rake::Task['source/_rev'].invoke
        else 
            puts "Failed to update document (#{resp.code.to_i})"
        end
    end

    Rake::Task[design_doc].invoke

end