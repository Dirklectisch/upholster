require 'rake'
require 'rake/clean'
require 'yajl'
require 'yaml'

BASE_FILES = FileList['render', 'config', File.join('config', 'database.yml'), File.join('render', '_id.txt')]
CLOBBER.include BASE_FILES

desc "Initialize new design document directory"
task :init => BASE_FILES

desc "Assemble renders into design document"
task :assemble => [:init, 'render.json']

directory 'render'
directory 'config'

desc "Render database configuration file"
file 'config/database.yml' => 'config' do |t|
  puts "Rendering #{t.name}"
  database_cfg = {:default => 'http://127.0.0.1:5984/upholster'}
  File.open('config/database.yml', 'w') {|f| f.write database_cfg.to_yaml}
end

desc "Render design document _id header element"
rule '_id.txt' do |t|
  
  puts "Rendering #{t.name}"
  File.open(t.name, 'w') do |f|
    dsgn_name = File.expand_path(t.name).pathmap('%-2d').pathmap('%1d')
    f.write '_design/' + dsgn_name
  end
  
end

CLEAN.include FileList[File.join('**', '*.json')]

desc "Assemble a JSON file from source directory"
rule '.json' => lambda {|file| 
    FileList[File.join(file.pathmap('%X'), '*')].collect do |file|
      File.directory?(file) ? file.pathmap('%X').ext('json') : file
    end.uniq.include file.pathmap('%X')
  } do |t|

    t.sources.pop

    puts "Assembling #{t.name} from #{t.sources}"   
    
    File.open(t.name, 'w') do |file|
            
      document = t.sources.collect do |path| 
        [path.pathmap('%x'), path.pathmap('%n'), File.read(path)]
      end.inject({}) do |doc, src| 
        src[2] = Yajl::Parser.parse(src[2]) if src[0] == '.json'
        doc[src[1]] = src[2]
        doc
      end
      
      json_encoder = Yajl::Encoder.new :pretty => true
      json_encoder.encode(document, file)
      
    end    
end