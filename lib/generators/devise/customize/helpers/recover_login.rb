require 'generators/cream/helpers/all'

module Devise
  module Customizers
    class RecoverLogin
      include Cream::GeneratorHelper        
      extend Rails3::Assist::UseMacro
      use_helpers :app, :special, :file, :model
      # include Devise::UserCustomization      

      attr_accessor :orm
  
      def initialize orm
        @orm = orm
      end
            
      def retrieve_password
        reset_password_instructions << find_recoverable_code
      end
    
      # should not be ORM dependent
      def reset_password_instructions
        %q{
  # Attempt to find a user by it's email. If a record is found, send new
  # password instructions to it. If not user is found, returns a new user
  # with an email not found error.
  def self.send_reset_password_instructions(attributes={})
    recoverable = find_recoverable_or_initialize_with_errors(reset_password_keys, attributes, :not_found)
    recoverable.send_reset_password_instructions if recoverable.persisted?
    recoverable
  end
  }
      end

      def find_recoverable_code
        %Q{
  def self.find_recoverable_or_initialize_with_errors(required_attributes, attributes, error=:invalid)
    case_insensitive_keys.each { |k| attributes[k].try(:downcase!) }

    attributes = attributes.slice(*required_attributes)
    attributes.delete_if { |key, value| value.blank? }

    if attributes.size == required_attributes.size
     if attributes.has_key?(:login)
        login = attributes.delete(:login)
        record = find_record(login)
     else  
       record = where(attributes).first
     end  
    end  
    user_record_not_found(required_attributes) unless record
    record
  end

  #{user_record_not_found}

  def self.find_record login
    #{Devise::QueryCustomizers::FindRecord.send orm}
  end
  }
      end

      def user_record_not_found
        %q{
  # handle when the user record is not found
  # adds error messages to the record
  def self.user_record_not_found(required_attributes)
    record = new

    required_attributes.each do |key|
    value = attributes[key]
    record.send("#{key}=", value)
    record.errors.add(key, value.present? ? error : :blank)
    end  
  end  
  }
      end
    end
  end
end