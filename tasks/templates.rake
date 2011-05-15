require 'rake'
require 'rake/clean'
require 'yaml'

CLEAN.include(File.join('**', 'template', '*.js'))

directory 'template'

desc "Create Closure Template compiler configuration file"
file File.join('config', 'soy.yml') => 'config' do |t|
  puts "Rendering #{t.name}"
  soy_cfg = {
    :jar => File.expand_path(File.join(File.dirname(__FILE__), '..', 'bin', 'SoyToJsSrcCompiler.jar')),
    :codeStyle => 'stringBuilder'
    }
  File.open('config/soy.yml', 'w') {|f| f.write soy_cfg.to_yaml}  
end

desc "Create Closure Javascript compiler configuration file"
file File.join('config', 'js.yml') => 'config' do |t|
  puts "Rendering #{t.name}"
  js_cfg = {
    :jar => File.expand_path(File.join(File.dirname(__FILE__), '..', 'bin', 'compiler.jar'))
    }
  File.open('config/js.yml', 'w') {|f| f.write js_cfg.to_yaml}  
end

desc "Render a JavaScript file"
rule Regexp.new(/render\/.*\.js$/) do |t|
  sh "java -jar #{CONFIG['soy'][:jar]} \
           --js #{t.source} \
           --js template/shared/soyutils.js \
           --js_output_file #{t.name}"
end

desc "Compile a .soy Closure Template"
rule Regexp.new(/template\/.*\.js$/) => '.soy' do |t|
  puts "Compiling #{t.name} template"
  begin
    sh "java -jar #{CONFIG['soy'][:jar]} --codeStyle #{CONFIG['soy'][:codeStyle]} --outputPathFormat #{t.name} #{t.source}"
  rescue Exception => e
    e.message
  end
  
  mime_type = 'html'
  
  File.open(t.name, 'a') do |f|
    f.puts "var templates = {};"
    f.puts "templates['#{mime_type}'] = #{mime_type}.body;"
  end
end