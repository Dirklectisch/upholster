require 'rake/resource_task.rb'

module Upholster
    
    def Upholster.resolve_design_path
        dsgn_name = File.expand_path(Dir.pwd).pathmap('%n')
        return File.join('_design/' + dsgn_name)
    end
    
    def Upholster.resolve_path fragment

        db_url = CONFIG[:database][:default]

        func_name = /_\w*\/\w*/ # _show/name/_id
        doc_id = /\w+/ # _id

        if fragment.match(func_name) 
            
            return File.join(db_url, Upholster.resolve_design_path, fragment)

        elsif fragment.match(doc_id) 
            
            return File.join(db_url, fragment)

        else
            raise ArgumentError, "Incorrect path" 
        end

    end

end