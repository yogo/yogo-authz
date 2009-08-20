# Yogo Authorization Module
# Copyright (c) 2009 Montana State University
#
# File: users_controller.rb
# The Users Controller is used to create and destroy users in the yogo system.
class YogoAuthz::UsersController < ApplicationController
  unloadable
  
  # before_filter :require_no_user, :only => [:new, :create]
  # before_filter :require_user, :only => [:show, :edit, :update]
  
  require_user
  authorize_group :sysadmin
  
  def index
    @users = WebUser.all
    
  end
  
  def new
    @user = YogoAuthz::User.new
  end
  
  def create
    @user = YogoAuthz::User.new(params[:yogo_authz_user])
    if @user.save
      flash[:notice] = "Account registered!"
      redirect_back_or_default account_url
    else
      render :action => :new
    end
  end
  
  def show
    @user =YogoAuthz::User.find(params[:id])
  end

  def edit
    @user =YogoAuthz::User.find(params[:id])
  end
  
  def update
    @user = @current_user # makes our views "cleaner" and more consistent
    if @user.update_attributes(params[:yogo_authz_user])
      flash[:notice] = "Account updated!"
      redirect_to account_url
    else
      render :action => :edit
    end
  end
  
  def destroy
    @user = YogoAuthz::User.find(params[:id])
    @user.destroy
    flash[:notice] = "User Destroyed"
    redirect_to users_path
  end
end
