require 'rake'
require 'rake/clean'
require 'rake/resource_task'
require 'yajl'
require 'rufus-verbs'

CLOBBER.include File.join('render', '_rev.txt')

include Rufus::Verbs

task :publish, [:database] do |t, args|
  args.with_defaults :database => CONFIG['database'][:default]
  design_doc = args.database + '/_design/' + File.expand_path(Dir.pwd).pathmap('%n')
  
  resource args.database do |rt|
    puts "Creating database #{rt.name}"
    resp = put(rt.name)
    if resp.code.to_i == 201
      puts "Database #{rt.name} Created"
    else
      puts "Database not created. (Error Code: #{resp.code.to_i})"
    end
  end
  
  file 'render/_rev' => args.database do |ft|
    puts "Updating document revision (#{ft.name})"
    resp = head(design_doc)
    case resp.code.to_i
    when 200      
      _rev = resp.header['Etag']
      File.open(File.join('render', '_rev.txt'), 'w'){|f| f.write _rev.slice(1, 34)}
      puts "Revision updated (_rev: #{_rev})"
    else
      puts "Document #{design_doc} not found"
    end
  end
  
  resource design_doc => ['render.json', args.database] do |rt|
    puts "Updating design document #{rt.name}"
    resp = put(rt.name) do |request|
      request['content-type'] = 'application/json'
      File.read('render.json')
    end
    case resp.code.to_i
    when 201
      Rake::Task['render/_rev'].invoke
      puts "Design document updated"
    when 409
      puts "Document update conflict"
      Rake::Task['render/_rev'].invoke
    else 
      puts "Failed to update document (#{resp.code.to_i})"
    end
  end
  
  Rake::Task[design_doc].invoke
  
end