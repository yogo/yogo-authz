# Yogo Authorization Module
# Copyright (c) 2009 Montana State University
#
# FILE: user.rb
# A User model for the Authlogic to use.
class YogoAuthz::User < ActiveRecord::Base
  acts_as_authentic do |config|
    config.validate_ldap_login false
  end
  
  def self.find_by_ldap_login(login)
    YogoAuthz::User.first(:conditions => {:login => login})
  end
  
  def self.create_with_ldap_data(login,password,user_data)
    password = create_random_password
    self.create(:login       => login,
                :password    => password, :password_confirmation => password,
                :email       => "#{user_data[:mail][0]}",
                :first_name  => "#{user_data[:givenname][0]}",
                :last_name   => "#{user_data[:sn][0]}")
  end
  
  def name
    "#{first_name} #{last_name}"
  end
  
  private
  
  def create_random_password
    "--#{(rand()-0.5)*100090}--#{DateTime.now}--"
  end
end