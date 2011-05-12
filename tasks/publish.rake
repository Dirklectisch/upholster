require 'rake'
require 'rake/resource_task'
require 'yajl'
require 'rufus-verbs'

CLEAN.include File.join('render', '_rev.txt')

include Rufus::Verbs

task :publish, [:database] do |t, args|
  args.with_defaults :database => 'http://dirklectisch.iriscouch.com/example'
  design_doc = args.database + '/_design/' + File.expand_path(Dir.pwd).pathmap('%n')
  
  resource args.database do |rt|
    puts "Creating database #{rt.name}"
    resp = put(rt.name)
    if resp.code.to_i == 201
      puts "Database Created"
    else
      puts "Database not created #{resp.code.to_i}"
    end
  end
  
  resource design_doc => ['render.json', args.database] do |rt|
    puts "Updating design document #{rt.name}"
    resp = put(rt.name) do |request|
      request['content-type'] = 'application/json'
      File.read('render.json')
    end
    if resp.code.to_i == 201
      _rev = resp.header['Etag']
      File.open(File.join('render', '_rev.txt'), 'w'){|f| f.write _rev.slice(1, 34)}
      puts "Design document updated (_rev: #{_rev})"
    elsif resp.code.to_i == 409
      _rev = head(rt.name).header['Etag']
      File.open(File.join('render', '_rev.txt'), 'w'){|f| f.write _rev.slice(1, 34)}
      puts "Update conflict saved new revision number (_rev: #{_rev})"
    else 
      puts "Failed to update document (#{resp.code.to_i})"
    end
  end
  
  Rake::Task[design_doc].invoke
  
end