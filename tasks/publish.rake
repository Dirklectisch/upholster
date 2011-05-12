require 'rake'
require 'rake/resource_task'
require 'yajl'
require 'rufus-verbs'

include Rufus::Verbs

task :publish, [:database] do |t, args|
  args.with_default :database => 'http://dirklectisch.iriscouch.com/example'
  design_doc = args.database + '/_design/' + Dir.pwd.pathmap('%-1d')
  
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
    puts resp.code.to_i
  end
  
  Rake::Task[design_doc].invoke
  
end