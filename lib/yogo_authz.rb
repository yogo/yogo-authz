# YogoAuthz

require File.dirname(__FILE__) + '/yogo_authz/extensions/routes'
require File.dirname(__FILE__) + '/yogo_authz/extensions/exceptions'
require File.dirname(__FILE__) + '/yogo_authz/yogo_user'
require File.dirname(__FILE__) + '/yogo_authz/authenticated_system'
require File.dirname(__FILE__) + '/yogo_authz/authorization_system'
require File.dirname(__FILE__) + '/yogo_authz/controller_helpers'
require File.dirname(__FILE__) + '/yogo_authz/authlogic_dm/compatability'

# TODO: Play with these load paths for gem usage.
# %w{ models controllers }.each do |dir|
#   path = File.join(File.dirname(__FILE__), 'app', dir, 'yogo_authz')
#   puts path
#   $LOAD_PATH << path
#   ActiveSupport::Dependencies.load_paths << path
#   ActiveSupport::Dependencies.load_once_paths.delete(path)
# end