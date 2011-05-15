require 'rake'
require 'rake/clean'
require 'yaml'

CLEAN.include(File.join('**', 'template', '*.js'))

directory 'template'

desc "Create Closure Template compiler configuration file"
file File.join('config', 'soy.yml') => 'config' do |t|
  puts "Rendering #{t.name}"
  database_cfg = {
    :jar => File.expand_path(File.join(File.dirname(__FILE__), '..', 'bin', 'SoyToJsSrcCompiler.jar')),
    :codeStyle => 'concat'
    }
  File.open('config/soy.yml', 'w') {|f| f.write database_cfg.to_yaml}  
end

desc "Compile a Closure Template"
rule '.js' => '.soy' do |t|
  begin
    sh "java -jar #{CONFIG['soy'][:jar]} --codeStyle #{CONFIG['soy'][:codeStyle]} --outputPathFormat #{t.name} #{t.source}"
  rescue Exception => e
    e.message
  end
end