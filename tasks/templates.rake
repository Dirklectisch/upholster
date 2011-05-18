require 'rake'
require 'rake/clean'
require 'yaml'

directory 'template'
directory 'stage'

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

desc "Stage a Javascript template"
rule Regexp.new(/stage\/[a-z]*_[a-z]*\.js$/) => lambda {|path|
  md = path.pathmap('%n').match(/([a-z]*)_([a-z]*)$/)
  FileList[File.join('template', 'shared', 'soyutils.js')] +
  FileList[File.join('template', md[1], md[2] + '*')].pathmap('%X%{.*,.js}x').uniq
  } do |t|

  puts "Staging #{t.name} JavaScript template from #{t.sources}"
  
  cmd = ''
  cmd << "java -jar #{CONFIG['js'][:jar]} "
  t.sources.each do |js|
    cmd << "--js #{js} "
  end
  cmd << "--js_output_file #{t.name}"
  
  sh cmd
end

desc "Render a single .soy Closure Template"
rule Regexp.new(/template\/.*\.js$/) => '.soy' do |t|
  
  options = CONFIG['soy'].dup
  
  cmd = String.new
  cmd << "java -jar #{options.shift[1]} "
  options.each do |opt|
    cmd << "--#{opt.first} #{opt.last} "
  end
  cmd << "--outputPathFormat #{t.name} #{t.source}"
  
  puts "Compiling #{t.name} template"
  begin
    sh cmd
  rescue Exception => e
    e.message
  end
end

desc "Preview rendered template in a browser"
task :preview, [:template] do |t, args|
  raise ArgumentError, "Incorrect template name" if !args.template.match(/_show\/[a-z]*$/)
  
  # _show/name/stub
  template_name = args.template.sub('_', '').sub('/', 's_')
  template_file = File.join('stage', template_name.concat('.js'))
  output_file = template_file.ext('html')
  Rake::Task[template_file].invoke
  
  begin
    sh "js -e \"var navigator={userAgent: \\\"\\\"};\" -f #{template_file} -e \"var opt_data = {}; print(templates.html(opt_data));\" > #{output_file}"
    sh "open #{output_file}"
  rescue Exception => e
    e.message
  end  
end
