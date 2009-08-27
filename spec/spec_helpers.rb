# begin
#   require File.dirname(__FILE__) + '/../../../../spec/spec_helper'
# rescue LoadError
#   puts "You need to install rspec in your base app"
#   exit
# end

require "rubygems"
require "active_record"
require 'dm-core'
require 'dm-timestamps'
require 'dm-validations'
require 'dm-is-nested_set'
require 'authlogic'
require File.dirname(__FILE__) + '/../lib/yogo_authz'
require 'factory_girl'

DataMapper.setup(:default, 'sqlite3::memory:')

# Stub user model for testing
class User
 include YogoAuthz::YogoUser

end
User.auto_migrate!

# Dir["factories/*.rb"].each{ |f| require f }

# plugin_spec_dir = File.dirname(File.expand_path(__FILE__))

# 
# DataMapper.setup(:default, databases[ENV["test"]])
# DataMapper.logger = Rails.logger

# This is the migration stuff for DataMapper
# Dir[File.join(plugin_spec_dir, "..", "app", "models", "yogo_authz", "*.rb")].each{ |f| require f }
