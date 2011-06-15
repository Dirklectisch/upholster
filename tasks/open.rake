require 'rake'

desc "Open CouchDB design doc method in a browser"
task :open, [:path] => 'config/database.yml' do |t, args|
  
  path_to_func = /_show\/[a-z]*$/ # _show/name/_id
  path_to_doc = /\w+/ # _id
  
  db_url = CONFIG['database'][:default]
  
  if args.path.match(path_to_func) 
    
    doc_name = '_design/' + File.expand_path(Dir.pwd).pathmap('%n')

    sh "open #{File.join(db_url, doc_name, args.path)}"
    
  elsif args.path.match(path_to_doc) 
    
    sh "open #{File.join(db_url, args.path)}"
    
  else
    raise ArgumentError, "Incorrect path" 
  end
  
end