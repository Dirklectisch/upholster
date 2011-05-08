require 'rake'

CLEAN.include(File.join('**', 'template', '*.js'))
CLOBBER.include('bin')

desc "Compile a Closure Template"
rule '.js' => '.soy' do |t|
  begin
    sh "java -jar bin/SoyToJsSrcCompiler.jar --codeStyle concat --outputPathFormat #{t.name} #{t.source}"
  rescue Exception => e
    e.message
  end
end

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