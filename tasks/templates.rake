require 'rake'
require 'rake/clean'

CLEAN.include(File.join('**', 'template', '*.js'))

directory 'template'

desc "Compile a Closure Template"
rule '.js' => '.soy' do |t|
  begin
    sh "java -jar bin/SoyToJsSrcCompiler.jar --codeStyle concat --outputPathFormat #{t.name} #{t.source}"
  rescue Exception => e
    e.message
  end
end