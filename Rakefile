require 'rake'
require 'rake/clean'
require 'yajl'

CLEAN.include FileList[File.join('**', '*.json')]

desc 'Assemble a document ID literal file'
file 'example/render.json' => 'example/render/_id.txt'

desc "Render design document _id header element"
rule '_id.txt' do |t|
  
  puts "Rendering #{t.name}"
  File.open(t.name, 'w') do |file|
    file.write '_design/' + t.name.pathmap('%-2d').pathmap('%1d')
  end
  
end

desc "Assemble a JSON file from source directory"
rule '.json' => lambda {|file| 
    FileList[File.join(file.pathmap('%X'), '*')].collect do |file|
      File.directory?(file) ? file.pathmap('%X').ext('json') : file
    end.uniq
  } do |t|
    
    # Raise an ArgumentError if one of the source files can not be found
    raise ArgumentError if t.sources.empty? || t.sources.all? {|src| !File.exist?(src)}

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