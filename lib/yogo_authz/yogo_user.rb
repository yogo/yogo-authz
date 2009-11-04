# Yogo Authorization Module
# Copyright (c) 2009 Montana State University
#
# FILE: yogo_user.rb
# This module provides properties for a user of a Yogo system.
module YogoAuthz
  module YogoUser

    def self.included(klass)
      klass.class_eval do
        include DataMapper::Resource
        include AuthlogicDM::Compatability

        attr_accessor :password_confirmation

        property :id,                 DataMapper::Types::Serial
        property :login,              String, :nullable => false, :index => true
        property :email,              String, :nullable => false, :length => 256
        property :first_name,         String, :nullable => false, :length => 50
        property :last_name,          String, :nullable => false, :length => 50  

        # TODO: Make sure a length of 128 is long enough for various encryption algorithms.
        property :crypted_password,   String, :nullable => false, :length => 128
        property :password_salt,      String, :nullable => false, :length => 128
        property :persistence_token,  String, :nullable => false, :index => true, :length => 128

        property :login_count,        Integer, :nullable => false, :default => 0
        property :failed_login_count, Integer, :nullable => false, :default => 0

        property :last_request_at,    DateTime
        property :last_login_at,      DateTime
        property :current_login_at,   DateTime
        # Long enough for an ipv6 address.
        property :last_login_ip,      String, :length => 36
        property :current_login_ip,   String, :length => 36

        property :created_at, DateTime
        property :created_on, Date

        property :updated_at, DateTime
        property :updated_on, Date

        has n, :memberships, :model => 'YogoAuthz::Membership'
        has n, :groups, :through => :memberships, :model => 'YogoAuthz::Group' 

        extend  ClassMethods
        include InstanceMethods

        acts_as_authentic do |config| 
          config.instance_eval do
           validates_uniqueness_of_email_field_options :scope => :id
           validate_login_field false
          end
        end
        
      end
    end

    module ClassMethods
      def find_by_login(login)
        self.first(:login => login)
      end
     
    end # Class Methods
    
    module InstanceMethods
      def name
        "#{first_name} #{last_name}"
      end

      def has_group?(value)
        @_list ||= self.groups.collect{|g| g.self_and_ancestors.collect(&:name) }.flatten
        @_list.include?(value.to_s)
      end
      
    end # InstanceMethods
    
  end #YogoUser
end #YogoAuthz