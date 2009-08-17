class YogoAuthz::Requirement
  include DataMapper::Resource
  
  property :id,               Serial
  property :require_user,     Boolean, :default => false
  property :require_no_user,  Boolean, :default => false
  property :controller_name,  String,  :index   => :unique
  property :action_name,      String,  :index   => :unique
  
  property :created_at, DateTime
  property :created_on, Date
 
  property :updated_at, DateTime
  property :updated_on, Date
  
end