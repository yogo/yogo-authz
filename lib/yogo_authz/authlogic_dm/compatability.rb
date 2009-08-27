module YogoAuthz
module AuthlogicDM
  module Compatability
    def self.included(klass)
      klass.class_eval do
        extend  ClassMethods
        include InstanceMethods
        
        include Authlogic::ActsAsAuthentic::Base
        include Authlogic::ActsAsAuthentic::Email
        include Authlogic::ActsAsAuthentic::LoggedInStatus
        include Authlogic::ActsAsAuthentic::Login
        include Authlogic::ActsAsAuthentic::MagicColumns
        include Authlogic::ActsAsAuthentic::Password
        include Authlogic::ActsAsAuthentic::PerishableToken
        include Authlogic::ActsAsAuthentic::PersistenceToken
        include Authlogic::ActsAsAuthentic::RestfulAuthentication
        include Authlogic::ActsAsAuthentic::SessionMaintenance
        include Authlogic::ActsAsAuthentic::SingleAccessToken
        include Authlogic::ActsAsAuthentic::ValidationsScope
        
        class << self
          alias validates_length_of validates_length
          alias validates_uniqueness_of validates_is_unique
          alias validates_confirmation_of validates_is_confirmed
          alias validates_presence_of validates_present
          alias validates_format_of validates_format
          alias validates_numericality_of validates_is_number
          
          alias find_by_id get
          
                  def define_callbacks *callbacks
                    callbacks.each do |method_name|
                      callback = method_name.scan /^(before|after)/
                      method = %{
                        def #{method_name} method_sym, options={}, &block
                          puts "Called #{method_name}: \#{method_sym}, \#{options.inspect}"
                          if block_given?
                            #{callback} :#{method_name}, method_sym, &block
                          else
                            #{callback} :#{method_name} do
                              if options[:if]
                                return false unless send(options[:if])
                              end
                              if options[:unless]
                                return false if send(options[:unless])
                              end
                              send method_sym
                            end
                          end
                        end
                        }
          
                      puts method
                      instance_eval method
            
                      define_method method_name do; end
                    end
                  end
        end
        alias changed? dirty?
        self.define_callbacks *%w(
                 before_validation
                 before_save
                 after_save
               )
        # Save the record and skip session maintenance all together.
        def save_without_session_maintenance(*args)
          self.skip_session_maintenance = true
          result = save()
          self.skip_session_maintenance = false
          result
        end
      end
      
      # class << self
      #         def < klass
      #           return true if klass == ::ActiveRecord::Base
      #           super(klass)
      #         end
      #       end
    end #self.include

 
    module ClassMethods
      
      def find_with_case(field, value, sensitivity = true)
    #    if sensitivity
    #      send("find_by_#{field}", value)
    #    else
    #      first(:conditions => ["LOWER(#{quoted_table_name}.#{field}) = ?", value.downcase])
    #    end
        first :email => value.downcase
      end

      def column_names
        properties.map {|property| property.name.to_s }
      end

      def named_scope name, options, &block
        define_method name do
          if block
            all(options.merge(block.call))
          else
            all(options)
          end
        end
      end

      def quoted_table_name
        "users"
      end

      def default_timezone
        :utc
      end

      def primary_key
        :id
      end

      # alias changed? dirty?
      # puts self.name
      # class << self
      #   alias find_by_id get
      # end
      
      protected
      
      def with_scope(query)
        options = if query.kind_of?(Hash)
          query[:find]
        else
          query.options
        end

        # merge the current scope with the passed in query
        with_exclusive_scope(self.query.merge(options)) { |*block_args| yield(*block_args) }
      end
    end #ClassMethods
    
    module InstanceMethods
      
      def method_missing method_name, *args, &block
        name = method_name.to_s
        super unless name[/_changed\?$/]
        dirty_attributes.include? name.scan /(.*)_changed\?$/
      end
      
      def readonly?
        self.frozen?
      end
      
    end #InstanceMethods
  end #Compatability
end #AuthlogicDM
end #YogoAuthz