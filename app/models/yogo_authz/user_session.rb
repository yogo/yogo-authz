# Yogo Authorization Module
# Copyright (c) 2009 Montana State University
#
# FILE: user_session.rb
# AuthLogic's user session object.
class YogoAuthz::UserSession < Authlogic::Session::Base
  # specify configuration here such as:
  # logout_on_timeout true
  # ... See the authlogic doc.
  
  # TODO: Make this configurable from somewhere else.
  # Users shouldn't have to touch this plug in to make it work.
  
  authenticate_with User
  
end