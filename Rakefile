require 'rake'

load File.join(File.dirname(__FILE__), 'tasks', 'admin.rake')

directory 'bin'

file 'bin/SoyToJsSrcCompiler.jar' => :closure_templates
file 'bin/soyutils.js' => :closure_templates
file 'bin/compiler.jar' => :closure_compiler

desc "Download and install excutables for compilation of closure templates"  
task :closure_templates => 'bin' do
  puts "Installing Closure Template utilities"
  begin
    sh "curl -G http://closure-templates.googlecode.com/files/closure-templates-for-javascript-latest.zip -o closure-templates.zip"
    sh "unzip closure-templates.zip SoyToJsSrcCompiler.jar soyutils.js -d bin"
    sh "rm closure-templates.zip"
  rescue Exception => e
    e.message
  end
end

desc "Download and install excutables for compilation of closure templates"
task :closure_compiler do  
  puts "Installing Closure Compiler utilities"
  begin
   sh "curl -G http://closure-compiler.googlecode.com/files/compiler-latest.zip -o closure-compiler.zip"
   sh "unzip closure-compiler.zip compiler.jar -d bin"
   sh "rm closure-compiler.zip"
  rescue Exception => e
    e.message
  end 
end
  
