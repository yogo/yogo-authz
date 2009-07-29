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

DataMapper.setup(:users, databases['users'])
DataMapper.logger = Rails.logger

# This is the migration stuff for DataMapper
Dir[File.join(plugin_spec_dir, "lib", "app", "models")].each{ |f| require f }
DataMapper.auto_migrate!

def load_default_data
  User.create(:login                 => "sysadmin",
              :first_name            => "System",
              :last_name             => "Administrator",
              :email                 => "acg-support@montana.edu",
              :password              => "password",
              :password_confirmation => "password"
              )
              
  User.create(:login                 => "dummy",
              :first_name            => "Dummy",
              :last_name             => "User",
              :email                 => "dummy@montana.edu",
              :password              => "password",
              :password_confirmation => "password"
              )
              
  default_group = Group.create(:name => 'default')
  g = Group.create(:name        => 'sysadmin',
                   :description => 'User group with full administrator priviliges.')
  g.move(:into => default_group)
  g = Group.create(:name        => 'committee member',
                   :description => 'committee member')
  g.move(:into => default_group)

  MemberShip.create(:web_user => WebUser.first(:login => 'sysadmin'),
                    :group    => Group.first(:name    => 'sysadmin'))

  MemberShip.create(:web_user => WebUser.first(:login => 'dummy'),
                    :group    => Group.first(:name    => 'commitee member'))
end