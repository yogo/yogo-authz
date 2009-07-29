# class Membership < ActiveRecord::Base
#   belongs_to :user
#   belongs_to :group
# end

class YogoAuthz::Membership
  include DataMapper::Resource
  def self.default_repository_name
    :users
  end
  
  property :id,     Serial
  
  belongs_to :group,    :model => 'YogoAuthz::Group'
  belongs_to :web_user, :model => 'YogoAuthz::WebUser'
end