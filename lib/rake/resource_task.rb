require 'rake'
autoload :Rufus, 'rufus-verbs'

module Rake
  
  class ResourceTask < Task
  
    def needed?
      !exsist? || out_of_date?(timestamp)
    end
    
    def exsist?
      http_response.code.to_i == 200
    end
    
    def timestamp
      begin
        DateTime.parse(http_response.header['Last-Modified'])
      rescue
        EARLY
      end
    end
        
    def out_of_date? stamp
      @prerequisites.any? { |n| application[n, @scope].timestamp > stamp}
    end
    
    def http_response
      @http_response ||= Rufus::Verbs.head(name)
    end
        
  end
  
end

def resource *args, &block
  Rake::ResourceTask.define_task(*args, &block)
end