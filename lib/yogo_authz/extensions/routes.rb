if defined?(ActionController::Routing::RouteSet)
  class ActionController::Routing::RouteSet
    def load_routes_with_yogo_authz!
      yogo_authz_routes = File.join(File.dirname(__FILE__),
                          %w{.. .. .. config yogo_authz_routes.rb})
      unless configuration_files.include? yogo_authz_routes
        add_configuration_file(yogo_authz_routes)
      end
      load_routes_without_yogo_authz!
    end
  
    alias_method_chain :load_routes!, :yogo_authz
  
  end
end
