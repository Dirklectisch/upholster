require 'rake'
require 'rake/clean'
require 'yajl'

dsgn_root = '/Users/dirk/Sites/upholster/example'

CLEAN.include FileList[File.join('**', '_id.txt')]

desc "Render design document _id header element"
rule '_id.txt' do |t|
  
  puts "Rendering #{t.name}"
  File.open(t.name, 'w') do |f|
    f.write '_design/' + dsgn_root.pathmap('%n')
  end
  
end 

CLEAN.include FileList[File.join('**', '*.json')]

desc "Assemble a JSON file from source directory"
rule '.json' => lambda {|file| 
    FileList[File.join(file.pathmap('%X'), '*')].collect do |file|
      File.directory?(file) ? file.pathmap('%X').ext('json') : file
    end.uniq
  } do |t|
    
    # Raise an ArgumentError if one of the source files can not be found
    if t.sources.empty? || t.sources.any? {|src| !File.exist?(src)}
      missing_src = t.sources.select{|src| !File.exist?(src)}
      begin
        missing_src.each do |src|
          puts "Manually invoking #{src} task"
          Rake::Task[src].invoke
        end 
      rescue Exception => e
        puts e.message
        raise ArgumentError, "Missing #{missing_src} to build #{t.name}" 
      end
    end

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

file 'example/render.json' => 'example/render/_id.txt'
