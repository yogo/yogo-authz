# Yogo Authorization Module
# Copyright (c) 2009 Montana State University
#
# File: memberships_controller.rb
# The Memberships Controller is used to manage what groups a user belongs to.
class YogoAuthz::MembershipsController < ApplicationController
  before_filter :set_user
  
  
  def show
    @user_memberships = @web_user.memberships
    @groups = YogoAuthz::Group.all - @web_user.groups
  end
  
  def create
    YogoAuthz::Membership.create(:web_user => @web_user,
                      :group => YogoAuthz::Group.get(params[:group_id]))
    
    respond_to do |format|
      format.html { redirect_to(user_membership_path(@web_user.id)) }
    end
  end
  
  def destroy
    @web_user.memberships.get(params[:membership_id]).destroy
    
    respond_to do |format|
      format.html { redirect_to(user_membership_path(@web_user.id)) }
    end
  end
  
  private
  
  def set_user
    @web_user = YogoAuthz::WebUser.get(params[:user_id])
    #TODO: If @web_user.nil? throw an error
  end
end
