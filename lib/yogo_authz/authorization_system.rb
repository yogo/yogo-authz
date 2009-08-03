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
      
      base.send :class_inheritable_array, :auth_requirements
      base.send :auth_requirements=, []
    
      base.send :hide_action, :auth_requirements, :auth_requirements=
    
      base.send :wants_logged_in
    
    end

    module AuthorizationSystemClassMethods
    
      # ouch ouch ouch 
      # This replaces the method defined in extlib, because we want the one
      # defined in inheritable_attributes.rb
      def class_inheritable_reader(*syms) #nodoc
        syms.each do |sym|
          next if sym.is_a?(Hash)
          class_eval <<-EOS
            def self.#{sym}                        # def self.before_add_for_comments
              read_inheritable_attribute(:#{sym})  #   read_inheritable_attribute(:before_add_for_comments)
            end                                    # end
                                                   #
            def #{sym}                             # def before_add_for_comments
              self.class.#{sym}                    #   self.class.before_add_for_comments
            end                                    # end
          EOS
        end
      end
    
      # This is where initialzation could be, should be happening.
      # Baised on options passed in, decide how to do it
      #
      # Example Usage
      #
      #   authorize_default
      #   authorize_group
      #   authorize_logged_in
      
      def require_authorization(type, options = {})
        options.assert_valid_keys(:if, :unless, :only, :only_if_logged_in?, :except, :redirect_url, :render_url, :status)
      
        unless @before_filter_declaired ||= false
          @before_filter_declared = true
          before_filter :check_authorization
        end
      
        self.auth_requirements ||=[]
        self.auth_requirements << {:type => type, :options  => options}
      end
    
    def method_missing(method_id, *arguments)
      method_type = method_id.to_s.match(/^(forbid|wants)_([_a-zA-Z]\w*)$/)
      super if method_type.nil?
      require_authorization(method_type[1], *arguments)
    end
    
    def forbid_handler(*arguements)
      logger.debug { "You shouldn't use forbid methods.\nDeny first, allow later." }
    end
    
    def reset_auth_requirements!
      self.auth_requirements.clear
    end
    
    end # module AuthorizationSystemClassMethods
  
    module AuthorizationSystemInstanceMethods
    
      protected
    
      # What to do when the user is denied
      def authorization_denied
        store_location
        flash[:notice] = "You've been denied."
        redirect_to '/'
        return false
      end
    
      # What to return when the user is authorized
      def authorized
        true
      end
    
      def check_authorization
        
        return authorization_denied if current_web_user.nil?
        return authorized if admin_groups.length > 0
        
        if controller_permissions.length.eql? 0
         return authorization_denied
        else
          return authorized
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
    
      def admin_groups
        current_web_user.groups.all(:sysadmin => true)
      end
    
    end # module AuthroizationSystemInstanceMethod
  
  end
end