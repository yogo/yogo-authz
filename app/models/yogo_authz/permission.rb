class YogoAuthz::Permission
  include DataMapper::Resource
  include YogoAuthz::ControllerHelpers 
  def self.default_repository_name
    :users
  end
  
  property :id,               Serial
  property :group_id,         Integer, :index => true
  property :controller_name,  String, :index => :unique
  property :action_name,      String, :index => :unique
  
  property :created_at, DateTime
  property :created_on, Date
 
  property :updated_at, DateTime
  property :updated_on, Date
  
  belongs_to :group, :model => 'YogoAuthz::Group'
  

end