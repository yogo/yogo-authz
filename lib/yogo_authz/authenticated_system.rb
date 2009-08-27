# Yogo Authorization Module
# Copyright (c) 2009 Montana State University
#
# FILE: authenticated_system.rb
# Implementing an authentication system.
module YogoAuthz
  module AuthenticatedSystem
    
    def self.included(base)
    
      base.send :include, AuthenticatedSystemInstanceMethods
      base.send :extend, AuthenticatedSystemClassMethods
    
      base.send :class_inheritable_accessor, :authenication_requirements
      base.send :authenication_requirements=, []
    
      base.send :class_inheritable_accessor, :declaired_auths
      base.send :declaired_auths=, false
    
      base.send :hide_action, 
                :authenication_requirements, 
                :authenication_requirements=,
                :declaired_auths,
                :declaired_auths=
    
      base.send :before_filter, :check_authentication_requirements
      
      base.send :helper_method, :logged_in?, :current_user
    end
    
    module AuthenticatedSystemClassMethods

      def require_authentication(type = nil, options = {})
        options.assert_valid_keys(:if, :unless, :only, :for, :except)
        
        unless self.declaired_auths ||= false
          filter_parameter_logging :password, :ldap_password
          self.declaired_auths = true
        end
        
        for key in [:only, :except, :for]
          if options.has_key?(key)
            options[key] = [options[key]] unless Array === options[key]
            options[key] = options[key].compact.collect{|v| v.to_sym}
          end
        end
        
        self.authenication_requirements ||=[]
        self.authenication_requirements << {:type => type, :options  => options} unless type.nil?
        
      end

      def require_user(options = {})
        require_authentication(:require_user, options)
      end
      alias_method :login_required, :require_user

      def require_no_user(options = {})
        require_authentication(:require_no_user, options)
      end

    end
    
    module AuthenticatedSystemInstanceMethods
      protected
      
        # Check to see if the user is logged in or not.
        def check_authentication_requirements
          requirements = self.class.authenication_requirements
          # Check the rules provided, don't check the database
          if !requirements.empty?
            requirements.each do |requirement|
              type    = requirement[:type]
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
              
              return send("#{type}")
            end
          else
            requirement = YogoAuthz::Requirement.first(:controller_name => params[:controller],
                                                       :action_name     => params[:action])
                                                       
            return true            if requirement.nil?
            return require_user    if requirement.require_user
            return require_no_user if requirement.require_no_user
            return true
          end

          return true
        end
        
        def current_user_session
          return @current_user_session if defined?(@current_user_session)
          @current_user_session = YogoAuthz::UserSession.find
        end

        def current_user
          return @current_user if defined?(@current_user)
          @current_user = current_user_session && current_user_session.record
        end
        
        def logged_in?
          !!current_user
        end
        
        def not_logged_in?
          !current_user
        end

        def require_user
          unless current_user
            store_location
            flash[:notice] = "You must be logged in to access this page"
            redirect_to new_user_session_url
            return false
          end
        end

        def require_no_user
          if current_user
            store_location
            flash[:notice] = "You must be logged out to access this page"
            redirect_to '/'
            return false
          end
        end

        def store_location
          session[:return_to] = request.request_uri
        end

        def redirect_back_or_default(default)
          redirect_to(session[:return_to] || default)
          session[:return_to] = nil
        end
        
    end
  end
end