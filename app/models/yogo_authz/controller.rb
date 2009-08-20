# Yogo Authorization Module
# Copyright (c) 2009 Montana State University
#
# FILE: controller.rb
# I think this should be a class containing the controllers, descriptions of the controllers.
class YogoAuthz::Controller
  include YogoAuthz::ControllerHelpers 
  
  def self.all
    @_controllers ||= self.get_controllers
  end
  
  def self.declaired_authentications
    @_declaired_auth_controllers ||= self.all.select{|cont| cont.declaired_auths }
  end
  
  def self.undeclaired_authorizations
    @_undeclaired_auth_controllers ||= self.all.select{|cont| !cont.declaired_auths }
  end
  
  def self.declaired_authorizations
    @_declaired_authz_controllers ||= self.all.select{|cont| cont.declaired_authz }
  end
  
  def self.undeclaired_authorizations
    @_undeclaired_authz_controllers ||= self.all.select{|cont| !cont.declaired_authz }
  end
end