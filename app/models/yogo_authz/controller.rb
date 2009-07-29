# Yogo Authorization Module
# Copyright (c) 2009 Montana State University
#
# FILE: controller.rb
# I think this should be a class containing the controllers, descriptions of the controllers.
class Controller
  include YogoAuthz::ControllerHelpers 
  # include DataMapper::Resource
  # def self.default_repository_name
  #   :users
  # end
  
  def self.all
    @_controllers ||= self.get_controllers
  end
end