require 'rake'

load File.join(File.dirname(__FILE__), 'tasks', 'admin.rake')
load File.join(File.dirname(__FILE__), 'tasks', 'templates.rake')

file 'bin/SoyToJsSrcCompiler.jar' => :deploy_compiler
file 'bin/soyutils.js' => :deploy_compiler

desc "Download and install excutables for compilation of closure templates"  
task :deploy_compiler do
  begin
    sh "curl -G http://closure-templates.googlecode.com/files/closure-templates-for-javascript-latest.zip -o closure-templates.zip"
    sh "unzip closure-templates.zip SoyToJsSrcCompiler.jar soyutils.js -d bin"
    sh "rm closure-templates.zip"
  rescue Exception => e
    e.message
  end
end