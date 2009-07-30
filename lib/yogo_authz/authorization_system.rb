# Yogo Authorization Module
# Copyright (c) 2009 Montana State University
#
# FILE: authorization_system.rb
# This adds authorization helpers to the system.
module YogoAuthz
  module AuthorizationSystem

    def self.included(base)
      base.send :include, AuthorizationSystemInstanceMethods
      base.send :extend, AuthorizationSystemClassMethods
    
    end

    module AuthorizationSystemClassMethods
    
      # This is where initialzation could be, should be happening.
      # Baised on options passed in, decide how to do it
      def require_authorization(options = {})
        options.assert_valid_keys(:if, :unless, :only_if_logged_in?, :except, :redirect_url, :render_url, :status)
      
        unless @before_filter_declaired ||= false
          @before_filter_declared = true
          before_filter :check_authorization
        end
      
      end
    
    end # module AuthorizationSystemClassMethods
  
    module AuthorizationSystemInstanceMethods
    
      protected
    
      # What to do when the user is denied
      def authorization_denied
        store_location
        flash[:notice] = "You've been denied."
        redirect_to '/users'
        return false
      end
    
      # What to return when the user is authorized
      def authorized
        true
      end
    
      def check_authorization
        if controller_permissions.length.eql? 0
          authorization_denied
        else
          authorized
        end
      end
    
      # The heart of the system.
      # Returns permissions the current user has for the current controller and action
      #
      def controller_permissions
        controller_name = self.class.name
        action_name     = self.action_name
      
        groups = current_web_user.groups
      
        permissions = groups.collect{ |g|
          g.self_and_ancestors.
            permissions.all(:controller_name => controller_name,
                            :action_name     => action_name)
        }
      
        return permissions.flatten
      end
    
    end # module AuthroizationSystemInstanceMethod
  
  end
end