require 'rake'
require 'rake/clean'
require 'yajl'
require 'yaml'

BASE_FILES ||= FileList.new

BASE_FILES.include FileList[
  'config',
  File.join('config', 'database.yml'),
  'source',
  File.join('source', '_id.txt')]

CLOBBER.include BASE_FILES

desc "Initialize new design document directory"
task :init => BASE_FILES

CLEAN.include 'source.json'

desc "Assemble sources into design document"
task :assemble => [:init, 'source.json']

directory 'source'
directory 'config'

desc "Render design document _id header element"
rule 'source/_id.txt' do |t|
  
  puts "Rendering #{t.name}"
  File.open(t.name, 'w') do |f|
    dsgn_name = File.expand_path(t.name).pathmap('%-2d').pathmap('%1d')
    f.write '_design/' + dsgn_name
  end
  
end

CLEAN.include FileList[File.join('source', '**', '*.json')]

desc "Assemble a JSON file from source directory"
rule '.json' => lambda {|file| 
  FileList[File.join(file.pathmap('%X'), '**', '*'), file.pathmap('%X')]
  } do |t|
  
  # Determine actual source files (instead of all prerequisites)
  t.sources = FileList[File.join(t.name.pathmap('%X'), '*')].map do |src|
    File.directory?(src) ? src.pathmap('%X').ext('json') : src
  end.uniq
        
  # Make sure all source file tasks are being invoked
  t.sources.each {|src| Rake::Task[src].invoke}
  
  puts "Assembling #{t.name} from #{t.sources}" 
    
  File.open(t.name, 'w') do |file|
          
    document = t.sources.collect do |path| 
      [path.pathmap('%x'), path.pathmap('%n'), File.read(path)]
    end.inject({}) do |doc, src| 
      src[2] = Yajl::Parser.parse(src[2]) if src[0] == '.json'
      #src[2] = src[2].gsub(/\s/,  '') if src[0] == '.js'
      doc[src[1]] = src[2]
      doc
    end
    
    json_encoder = Yajl::Encoder.new :pretty => true
    json_encoder.encode(document, file)
    
  end
end