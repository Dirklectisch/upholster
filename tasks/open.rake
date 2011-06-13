require 'rake'

desc "Open CouchDB design doc method in a browser"
task :open, [:path] do |t, args|
  raise ArgumentError, "Incorrect path" if !args.path.match(/_show\/[a-z]*$/)
  
  # _show/name/stub
  db_url = CONFIG['database'][:default]
  doc_name = '_design/' + File.expand_path(Dir.pwd).pathmap('%n')
  
  sh "open #{File.join(db_url, doc_name, args.path)}"
  
end