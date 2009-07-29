ActionController::Routing::Routes.draw do |map|
  map.resource :account, :controller => "yogo_authz/users"
  map.resources :users, :controller => "yogo_authz/users" do |user|
    user.resource :membership, :controller => "yogo_authz/memberships", :except => [:update, :new]
  end
  
  map.resources :groups, :controller => "yogo_authz/groups" do |group|
    group.resource :permission, :controller => "yogo_authz/permissions"
  end
  
  map.resource :user_session, :controller => "yogo_authz/user_sessions"
  map.root :controller => "yogo_authz/user_sessions", :action => "new"
end