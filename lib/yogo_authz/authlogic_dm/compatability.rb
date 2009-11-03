module YogoAuthz #:nodoc:
# This is a compatability layer for authlogic to use datamapper.
module AuthlogicDM #:nodoc:
  module Compatability #:nodoc:
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

               # puts method
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
            puts "in save_without_session_maintence"
            puts "skip_session_maintence_true"
            self.skip_session_maintenance = true
            puts "result = save()"
            result = save!() # I think this is datamapper's save
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
       if sensitivity
         self.first(field => value)
       else
         first(:conditions => ["LOWER(#{quoted_table_name}.#{field}) = ?", value.downcase])
       end
        first(:email => value.downcase)
      end


      def column_names
        properties.map {|property| property.name.to_s }
      end

      def named_scope(name, options = {}, &block)
        puts "Defining scope: #{name}"
        (class << self; self end).instance_eval do
           define_method name do
             case options
             when Hash
               all(option)
             when Proc
               all(options.call)
             end
             # if block
             #             results = block.call
             #             puts options.class
             #             all(options.merge(results))
             #           else
             #             puts options.class
             #             all(options)
             #           end
           end
         end
        # method = %{
        #   def self.#{name}(options = {}, &block)
        #     if block
        #       all(options.merge(block.call))
        #     else
        #       all(options)
        #     end
        #   end
        # }
        # class_eval(method)
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

      def logged_in
        all(:conditions => ['last_request_at > ?', logged_in_timeout.seconds.ago])
      end

      def logged_out
        all(:conditions => ["last_request_at is NULL or last_request_at <= ?", logged_in_timeout.seconds.ago])
      end


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

      def method_missing(method_name, *args, &block)
        name = method_name.to_s
        super unless name[/_changed\?$/]
        dirty_attributes.include?(name.scan(/(.*)_changed\?$/))
      end

      def readonly?
        self.frozen?
      end

      def new_record?
        self.new?
      end

    end #InstanceMethods
  end #Compatability
end #AuthlogicDM
end #YogoAuthz