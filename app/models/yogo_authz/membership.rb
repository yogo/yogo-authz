# class Membership < ActiveRecord::Base
#   belongs_to :user
#   belongs_to :group
# end

class YogoAuthz::Membership
  include DataMapper::Resource
  
  property :id,     Serial
  
  belongs_to :group,    :model => 'YogoAuthz::Group'
  belongs_to :web_user, :model => 'YogoAuthz::WebUser'
end