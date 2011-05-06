require 'rake'

CLOBBER.include('bin')

namespace "deploy" do
  
  task :closure_templates do
    begin
      sh "curl -G http://closure-templates.googlecode.com/files/closure-templates-for-javascript-latest.zip -o closure-templates.zip"
      sh "unzip closure-templates.zip SoyToJsSrcCompiler.jar soyutils.js -d bin"
      sh "rm closure-templates.zip"
    rescue Exception => e
      e.message
    end
  end
  
end