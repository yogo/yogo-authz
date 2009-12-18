# Yogo Authorization Module
# Copyright (c) 2009 Montana State University
#
# FILE: group.rb
# A Group is a nested set. Users can belong to groups through memberships.
class Yogo::Group
  include DataMapper::Resource
  
  is_nested_set
  
  property :id,           Serial
  property :name,         String, :required => true, :unique => true
  property :description,  String
  property :sysadmin,     Boolean, :required => true, :default => false
  
  property :created_at, DateTime
  property :created_on, Date
 
  property :updated_at, DateTime
  property :updated_on, Date
  
  
  has n, :memberships, :model => 'Yogo::Membership'
  has n, :users, :through => :memberships,  :model => 'User'
  
  has n, :permissions, :model => 'Yogo::Permission'
  
  def to_s
    name
  end
  
end