module YogoAuthz
  module AuthenticatedSystem
    
    def self.included(base)
    
      base.send :include, AuthenticatedSystemInstanceMethods
      base.send :extend, AuthenticatedSystemClassMethods
    
      base.send :require_authentication
    end
    
    module AuthenticatedSystemClassMethods
      
      def require_authentication
        
        unless @before_authentication_filter_declaired ||= false
          before_filter :check_authenticated
          @before_authentication_filter_declaired = true
        end
        
      end
        
    end
    
    module AuthenticatedSystemInstanceMethods
      private
      
        # The heart of the authentication system.
        # Check to see if the user is logged in or not.
        def check_authenticated

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
            redirect_to account_url
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