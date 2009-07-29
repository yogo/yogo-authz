# Yogo Authorization Module
# Copyright (c) 2009 Montana State University
#
# FILE: group.rb
# A Group is a nested set. Users can belong to groups through memberships.
class YogoAuthz::Group
  include DataMapper::Resource
  
  is_nested_set
  
  property :id,           Serial
  property :name,         String, :nullable => false, :unique => true
  property :description,  String
  property :parent_id,    Integer
  
  property :created_at, DateTime
  property :created_on, Date
 
  property :updated_at, DateTime
  property :updated_on, Date
  
  
  has n, :memberships, :model => 'YogoAuthz::Membership'
  has n, :web_users, :through => :memberships,  :model => 'YogoAuthz::WebUser'
  
  has n, :permissions, :model => 'YogoAuthz::Permission'
  
  def to_s
    name
  end
  
end