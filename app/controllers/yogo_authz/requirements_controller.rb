# Yogo Authorization Module
# Copyright (c) 2009 Montana State University
#
# File: authentications_controller.rb
# The Authentications Controller is used to set if a controller/action requires a logged in user,
# a user who is not logged in, or doesn't care.

class YogoAuthz::RequirementsController < ApplicationController
  unloadable
  
  require_user
  authorize_group :sysadmin
  
  def index
    @controllers = YogoAuthz::Controller.undeclaired_authentications
    
    respond_to do |format|
      format.html
    end
  end
  
  def add_user
    @requirement = YogoAuthz::Requirement.get(params[:id])
    @requirement.require_user = true
    @requirement.require_no_user = false
    @requirement.save 
    
    respond_to do |format|
      format.html { redirect_to(requirements_url) }
    end
  end
  
  def add_no_user
    @requirement = YogoAuthz::Requirement.get(params[:id])
    @requirement.require_user = false
    @requirement.require_no_user = true
    @requirement.save
    
    respond_to do |format|
      format.html { redirect_to(requirements_url) }
    end
  end
  
  def remove
    @requirement = YogoAuthz::Requirement.get(params[:id])
    @requirement.require_user = false
    @requirement.require_no_user = false
    @requirement.save
    
    respond_to do |format|
      format.html { redirect_to(requirements_url) }
    end
  end
end