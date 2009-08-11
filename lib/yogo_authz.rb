# YogoAuthz

require 'yogo_authz/extensions/routes'
require 'yogo_authz/extensions/exceptions'

require 'yogo_authz/authenticated_system'
require 'yogo_authz/authorization_system'
require 'yogo_authz/controller_helpers'

# TODO: Play with these load paths for gem usage.
# %w{ models controllers }.each do |dir|
#   path = File.join(File.dirname(__FILE__), 'app', dir, 'yogo_authz')
#   puts path
#   $LOAD_PATH << path
#   ActiveSupport::Dependencies.load_paths << path
#   ActiveSupport::Dependencies.load_once_paths.delete(path)
# end