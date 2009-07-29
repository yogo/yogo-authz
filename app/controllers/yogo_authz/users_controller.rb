# Yogo Authorization Module
# Copyright (c) 2009 Montana State University
#
# File: users_controller.rb
# The Users Controller is used to create and destroy users in the yogo system.
class YogoAuthz::UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:show, :edit, :update]
  
  # require_authorization
  
  def index
    @users = YogoAuthz::WebUser.all
  end
  
  def new
    @user = YogoAuthz::User.new
  end
  
  def create
    @user = YogoAuthz::User.new(params[:user])
    if @user.save
      flash[:notice] = "Account registered!"
      redirect_back_or_default account_url
    else
      render :action => :new
    end
  end
  
  def show
    @user = @current_user
  end

  def edit
    @user = @current_user
  end
  
  def update
    @user = @current_user # makes our views "cleaner" and more consistent
    if @user.update_attributes(params[:user])
      flash[:notice] = "Account updated!"
      redirect_to account_url
    else
      render :action => :edit
    end
  end
end
