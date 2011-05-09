require 'rake'
require 'rake/resource_task'
require 'rufus-verbs'

include Rufus::Verbs

resource 'http://dirklectisch.iriscouch.com/rake' do |t|
  resp = put(t.name)
  if resp.code.to_i == 201
    puts "Database Created"
  end
end