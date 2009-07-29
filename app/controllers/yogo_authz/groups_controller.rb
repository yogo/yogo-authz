# Yogo Authorization Module
# Copyright (c) 2009 Montana State University
#
# File: groups_controller.rb
# The Groups Controller is used to create and destroy groups used in the yogo system.
class YogoAuthz::GroupsController < ApplicationController

  # require_authorization
  
  def index
    @groups = YogoAuthz::Group.all
    
    respond_to do |format|
      format.html
    end  
  end
  
  def show
    @group = YogoAuthz::Group.get(params[:id])
    
    respond_to do |format|
      format.html
    end
  end
  
  def new
    @group = YogoAuthz::Group.new
    
    respond_to do |format|
      format.html
    end
  end
  
  def edit
    @group = YogoAuthz::Group.get(params[:id])
    
    respond_to do |format|
      format.html
    end
  end
  
  def create
    parent_id = params[:group][:parent_id].to_i
    @group = YogoAuthz::Group.new(params[:group])
    
    respond_to do |format|
      if @group.save
        @group.move(:into => Group.get(parent_id)) if parent_id > 0
        flash[:notice] = "Group was successfully created."
        format.html { redirect_to(group_url(@group.id)) }
      else
        format.html { render(:action => "new")}
      end
    end
  end
  
  def update
    parent_id = params[:group][:parent_id]
    @group = YogoAuthz::Group.get(params[:id])
    
    if !parent_id.empty? && @group.parent_id != parent_id.to_i
      @group.move(:into => YogoAuthz::Group.get(parent_id))
    end
    
    respond_to do |format|
      if @group.update(params[:group])
        flash[:notice] = "Group was successfully updated."
        format.html { redirect_to(group_url(@group.id)) }
      else
        format.html { render :action => "edit"}
      end
    end
  end
  
  def destroy
    YogoAuthz::Group.get(params[:id]).destroy
    
    respond_to do |format|
      format.html { redirect_to(groups_path) }
    end
  end
  
end
