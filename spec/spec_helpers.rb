begin
  require File.dirname(__FILE__) + '/../../../../spec/spec_helper'
rescue LoadError
  puts "You need to install rspec in your base app"
  exit
end
 
plugin_spec_dir = File.dirname(File.expand_path(__FILE__))
ActiveRecord::Base.logger = Logger.new(plugin_spec_dir + "/debug.log")

databases = YAML::load(IO.read(plugin_spec_dir + "/db/database.yml"))

ActiveRecord::Base.establish_connection(databases[ENV["DB"] || "sqlite3"])

databases['users']['database'] = plugin_spec_dir + "/" + databases['users']['database']

DataMapper.setup(:default, databases[ENV["DB"] || "users"])
DataMapper.logger = Rails.logger

# This is the migration stuff for DataMapper
puts plugin_spec_dir
Dir[File.join(plugin_spec_dir, "..", "app", "models", "yogo_authz", "*.rb")].each{ |f| require f }
DataMapper.auto_migrate!

