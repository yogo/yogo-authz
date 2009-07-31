# desc "Explaining what the task does"
# task :yogo_authz do
#   # Task goes here
# end
namespace :yogo_authz do
  
  desc "Load Default authz information."
  task :load_default_info => :environment do
    YogoAuthz::Membership.auto_migrate!
    YogoAuthz::Permission.auto_migrate!
    YogoAuthz::WebUser.auto_migrate!
    YogoAuthz::Group.auto_migrate!
    
    YogoAuthz::User.create(:login => "sysadmin",
                :first_name            => "System",
                :last_name             => "Administrator",
                :email                 => "acg-support@montana.edu",
                :password              => "password",
                :password_confirmation => "password"
                )
              
    user = YogoAuthz::WebUser.first(:login => 'sysadmin')
    
    default_group = YogoAuthz::Group.create(:name => 'default')
    YogoAuthz::Group.create(:parent      => default_group, 
                            :name        => 'sysadmin',
                            :description => 'User group with full administrator priviliges.')
                            
    YogoAuthz::Group.create(:parent      => default_group, 
                            :name        => 'committee member',
                            :description => 'committee member')
                            

    YogoAuthz::Group.create(:parent      => default_group, 
                            :name        => 'administrator',
                            :description => 'administrator')
    
    YogoAuthz::Membership.create(:web_user => user, 
                      :group => YogoAuthz::Group.first(:name => 'sysadmin'))
  end
  
end
