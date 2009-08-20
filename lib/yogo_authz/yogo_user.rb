module YogoAuthz
  module YogoUser
    
    def is_yogo_user
      include DataMapper::Resource

      storage_names[:default] = 'users'

      property :id,                 DataMapper::Types::Serial
      property :login,              String, :nullable => false, :index => true
      property :email,              String, :nullable => false, :length => 256
      property :first_name,         String, :nullable => false, :length => 50
      property :last_name,          String, :nullable => false, :length => 50  

      property :crypted_password,   String, :nullable => false, :accessor => :private
      property :password_salt,      String, :nullable => false, :accessor => :private
      property :persistence_token,  String, :nullable => false, :accessor => :private, :index => true

      property :login_count,        Integer, :nullable => false, :default => 0, :writer => :private
      property :failed_login_count, Integer, :nullable => false, :default => 0, :writer => :private

      property :last_request_at,    DateTime, :writer => :private
      property :last_login_at,      DateTime, :writer => :private
      property :current_login_at,   DateTime, :writer => :private
      # Long enough for an ipv6 address.
      property :last_login_ip,      String, :length => 36, :writer => :private 
      property :current_login_ip,   String, :length => 36, :writer => :private

      property :created_at, DateTime
      property :created_on, Date

      property :updated_at, DateTime
      property :updated_on, Date

      has n, :memberships, :model => 'YogoAuthz::Membership'
      has n, :groups, :through => :memberships, :model => 'YogoAuthz::Group' 
      
      include YogoAuthz::YogoUser::InstanceMethods
      
    end
    
    module InstanceMethods
      def name
        "#{first_name} #{last_name}"
      end

      def has_group?(value)
        all_groups = self.groups.collect{|g| g.self_and_ancestors }.flatten
        puts all_groups
        !all_groups.select{|gr| gr.name.eql? value.to_s}.empty?
      end
      
    end # InstanceMethods
    
    # This kind of makes me feel icky, but it works.
    Object.send(:include, self)
  end #YogoUser
end #YogoAuthz