require 'rake'
require 'rake/clean'
require 'yajl'

dsgn_name = 'example'

# Load Rake Tasks
FileList[File.join('tasks', '*')].each{|p| load p}

# Initialize JSON parser and encoder
JSONEncoder = Yajl::Encoder.new :pretty => true
JSONParser = Yajl::Parser.new :symbolize_keys => true

# Find previously rendered files
RENDERS = FileList[File.join(dsgn_name, 'render', '**', '*.json')]
RENDERS.include FileList[File.join(dsgn_name, 'render', '_*')]

desc "Remove temporary files created during the build process."
CLEAN.include(RENDERS)

desc "Remove all files generated during the build process."
CLOBBER.include(File.join(dsgn_name, '*.json'))

# Determine which files need to be rendered
DSGN_DIRS = FileList[File.join(dsgn_name, 'render', '**', '*')].pathmap('%d').uniq
DSGN_HEAD = FileList[File.join(dsgn_name, 'render', '_id.txt')]
DSGN_BODY = DSGN_DIRS.ext('.json').reverse

desc "Assemble a JSON file from source directory"
rule '.json' => lambda { |file| file.pathmap('%X')} do |t|
  leaf_files = FileList[File.join(t.source, '*.*')]
  leafs = parse_leafs(leaf_files)
  File.open(t.name, 'w'){|f| f.puts JSONEncoder.encode(leafs)}
  puts "Assembled #{t.name} from source directory"
end

desc "Render design document _id header element"
rule '_id.txt' do |t|
  id = '_design/' + t.name.pathmap('%-2d').pathmap('%1d')
  File.open(t.name, 'w'){|f| f.write id}
  puts "Rendered #{t.name}"
end

desc "Render the design document"
task :assemble => [*DSGN_HEAD, *DSGN_BODY]

# Helper functions

def parse_leafs file_list
  
  hash = file_list.inject({}) do |result, path|
      
    case path.pathmap('%x')
    when 'js'
      content = File.read(path)
    when '.json'
      content = JSONParser.parse(File.read(path))
    else
      content = File.read(path)
    end
    
    result[path.pathmap('%n')] = content
    result
    
  end
  
  hash
  
end