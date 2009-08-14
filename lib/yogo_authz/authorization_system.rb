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
      
      base.send :class_inheritable_array, :authorization_requirements
      base.send :authorization_requirements=, []
    
      base.send :hide_action, :authorization_requirements, :authorization_requirements=
    
      # base.send :wants_logged_in
    
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
      
      def require_authorization(type, options = {})
        options.assert_valid_keys(:if, :unless, :only, :for, :only_if_logged_in?, :except, :redirect_url, :render_url, :status)
      
        unless @before_filter_declaired ||= false
          @before_filter_declared = true
          before_filter :check_authorization
        end
      
        for key in [:only, :except]
          if options.has_key?(key)
            options[key] = [options[key]] unless Array === options[key]
            options[key] = options[key].compact.collect{|v| v.to_sym}
          end
        end
      
        self.authorization_requirements ||=[]
        self.authorization_requirements << {:type => type, :options  => options}
      end
    
    def method_missing(method_id, *arguments)
      method_type = method_id.to_s.match(/^(forbid|wants)_([_a-zA-Z]\w*)$/)
      super if method_type.nil?
      require_authorization(method_type[2], *arguments)
    end
    
    def forbid_handler(*arguements)
      logger.debug { "You shouldn't use forbid methods.\nDeny first, allow later." }
      # But isn't this fun.
    end
    
    # Returns the action that should be taken
    def next_authorized_action_for(web_user, params = {}, binding = self.binding)
      return nil unless Array===self.auth_requirements
      self.authorization_requirements.each do |requirement|
        type = requirement[:type]
        options = requirement[:options]
        
        if options.has_key?(:only)
          next unless options[:only].include?( (params[:action]||"index").to_sym )
        end
        
        if options.has_key?(:for)
          next unless options[:for].include?( (params[:action]||"index").to_sym )
        end
        
        if options.has_key?(:except)
          next if options[:except].include?( (params[:action]||"index").to_sym )
        end
        
        if options.has_key?(:if)
          next unless ( String==options[:if] ? eval(options[:if], binding) : options[:if].call(params) )
        end
        
        if options.has_key?(:unless)
          next if ( String===options[:unless] ? eval(options[:unless], binding) : options[:unless].call(params) )
        end
        
        puts type
        
        # values.each{
                 return { :url => options[:redirect_url], :status => options[:status] } unless 
                 (web_user and controller_permissions(web_user, params))
               # } unless (web_user == :false || web_user == false)
               
      end
      return nil
    end
    
    def url_authorized?(web_user, params = {}, binding = self.binding)
      unless self.next_authorized_action_for(web_user, params, binding)
        return false
      end
      return true
    end
    
    # The heart of the system.
     # Returns permissions the given user has for the current controller and action
     #
     def controller_permissions(web_user = nil, params = {})
       controller_name = params[:controller]
       action_name     = params[:action]
     
       groups = current_web_user.groups
     
       permissions = groups.collect{ |g|
         g.self_and_ancestors.
           permissions.all(:controller_name => controller_name,
                           :action_name     => action_name)
       }
     
       return permissions.flatten
     end
    
    def reset_authorization_requirements!
      self.authorization_requirements.clear
    end
    

    
    end # module AuthorizationSystemClassMethods
  
    module AuthorizationSystemInstanceMethods
    
      protected
    
      # What to do when the user is denied?
      def authorization_denied
        store_location
        flash[:notice] = "You've been denied."
        redirect_to new_user_session_url
        return false
      end
    
      # What to return when the user is authorized
      def authorized
        true
      end
    
      def check_authorization
        # return authorization_denied if current_web_user.nil?
        # return authorized if admin_groups.length > 0
        return authorization_denied unless self.url_authorized?(params)
        return authorized
      end
    
      def admin_groups
        current_web_user.groups.all(:sysadmin => true)
      end
      
      def url_authorized?(params = {})
        params = params.symbolize_keys
        if params[:controller]
          base = eval("#{params[:controller]}_controller".classify)
        else
          base = self.class
        end
        base.url_authorized?(current_web_user, params, binding)  
      end
    
    end # module AuthroizationSystemInstanceMethod
  
  end
end