require 'rake'
require 'rake/clean'
require 'yajl'

root_path = 'example'

Encoder = Yajl::Encoder.new :pretty => true

CLEAN.include(File.join(root_path, 'shows.json'))

# Initialize source files
SRC_SHOWS = FileList[File.join(root_path, 'shows', '*.js')]

desc "Assemble show functions"
file "#{root_path}/shows.json" => SRC_SHOWS do
  shows = read_files(SRC_SHOWS)
  File.open("#{root_path}/shows.json", 'w'){|f| f.puts Encoder.encode(shows)}
end

# Helper functions

def read_files file_list
  
  hash = file_list.inject({}) do |result, file|  
    name = file.pathmap('%n')
    source = File.read(file)   
    result[name] = source
    
    result  
  end
  
  hash
  
end