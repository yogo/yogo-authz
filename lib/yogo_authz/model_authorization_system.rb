# Copyright (c) 2009 Montana State University
#
# FILE: model_authorization_system.rb
# This adds authorization helpers controllers and actions.
module YogoAuthz
  module ModelAuthorizationSystem
    
    def self.included(base)
      base.send :include, ClassMethods
      base.send :extend, InstanceMethods
    end
    
    module ClassMethods
      
      property :yogo_authz_something,      Serial
      property :yogo_authz_string,         String
      
      has n, :groups, :model => 'YogoAuthz::Groups'
    end
    
    module InstanceMethods
      
      def permit?
        
      end
      
    end
    
  end
end