require 'rake'

# Load application specific library paths
libdirs = FileList[File.join('.', '**', 'lib')]
ENV['RUBYLIB'] = libdirs.join(':')

libdirs.each do |path|
  $LOAD_PATH.unshift path.to_s
end

# Load application specific libraries
libfiles = FileList[File.join('.', '**', 'lib', '*.rb')].pathmap('%n')
ENV['RUBYOPT'] = '-r ' + libfiles.join(' ')

require *libfiles

desc "Open an irb session preloaded with paths"
task :console do
  sh "irb --simple-prompt"
end