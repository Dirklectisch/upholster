require 'rake/resource_task.rb'

module Upholster
    
    def Upholster.resolve_path fragment

        db_url = CONFIG[:database][:default]

        func_name = /_\w*\/\w*/ # _show/name/_id
        doc_id = /\w+/ # _id

        if fragment.match(func_name) 
            
            doc_name = '_design/' + File.expand_path(Dir.pwd).pathmap('%n')
            return File.join(db_url, doc_name, fragment)

        elsif fragment.match(doc_id) 
            
            return File.join(db_url, fragment)

        else
            raise ArgumentError, "Incorrect path" 
        end

    end

end