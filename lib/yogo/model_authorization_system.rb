# Copyright (c) 2009 Montana State University
#
# FILE: model_authorization_system.rb
# This adds authorization helpers controllers and actions.
module Yogo
  module ModelAuthorizationSystem
    
    def self.included(base)

      eval <<-END_CLASS
             class Yogo::#{base.name}Group < Yogo::Group
                belongs_to :#{base.name.underscore}, :model => "#{base.name}", :child_key => [:foreign_id]
             end
           END_CLASS
           
      
      base.send :extend, ClassMethods
      base.send :include, InstanceMethods

      base.send(:property, :yogo_string, String)
      # 1.0/0 is the same as 'n'
      base.send(:has, 1.0/0, :groups, :model => "Yogo::#{base.name}Group", :child_key => [:foreign_id])
      base.send(:has, 1.0/0, :users, :through => :groups, :model => "User")

      # include Yogo::ModelAuthorizationSystem::ClassMethods
      # extend Yogo::ModelAuthorizationSystem::InstanceMethods
      
    end
    
    module ClassMethods

      def add_routes(map, parents = [])
        generate_groups_controller(parents)
        map.namespace :yogo do |yogo|
          yogo.resources :groups, :controller => "#{self.name.underscore}_groups"
        end
      end

      private
      
      def generate_groups_controller(parents)
        # class_name = @self.name
        # class_var = @self.name.underscore
        eval <<-END_CLASS
          class Yogo::#{self.name}GroupsController < ApplicationController
            before_filter :find_#{self.name.underscore}

            def index
              @groups = @parent.groups
              render(:template => 'yogo/tmp_groups/index')
            end
            
            def show
              @group = @parent.groups.find(params[:id])
              render(:template => 'yogo/tmp_groups/index')
              
              render(:template => 'yogo/tmp_groups/show')
            end
            
            def new
              @group = @parent.groups.new
              
              render(:template => 'yogo/tmp_groups/new')
            end

            private

            def find_#{self.name.underscore}
              puts "Finding " + #{self.name}.to_s
              @parent = #{self.name}.first(:id => params[:#{self.name.underscore}_id]) ||
                                          #{self.name}.first(:name => params[:#{self.name.underscore}_id])

            end
            
            def parent_path
              
            end
          end
        END_CLASS
      end

    end
    
    module InstanceMethods
      
      def permit?
        true
      end
      
    end
    
  end
end