module YogoAuthz
  module AuthenticatedSystem
    
    def self.included(base)
    
      base.send :include, AuthenticatedSystemInstanceMethods
      base.send :extend, AuthenticatedSystemClassMethods
    
      base.send :class_inheritable_array, :authenication_requirements
      base.send :authenication_requirements=, []
    
      base.send :hide_action, :authenication_requirements, :authenication_requirements=
    
      base.send :require_authentication
    end
    
    module AuthenticatedSystemClassMethods
      
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
      
      # 
      # 
      def require_authentication(type = nil, options = {})
        options.assert_valid_keys(:if, :unless, :only, :for, :except)
        
        unless @before_authentication_filter_declaired ||= false
          before_filter :check_authentication_requirements
          filter_parameter_logging :password, :ldap_password
          @before_authentication_filter_declaired = true
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
      
        # The heart of the authentication system.
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
            # TODO: Implement database checks
            # We check the database for stuff here.
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

        def current_web_user
          if current_user
            return @current_web_user if defined?(@current_web_user)
            @current_web_user = YogoAuthz::WebUser.get(current_user.id)
          end
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