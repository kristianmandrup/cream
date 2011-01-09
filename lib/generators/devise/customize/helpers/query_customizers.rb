module Devise
  module QueryCustomizers
    module FindRecord
      class << self
        def active_record
          %q{where(attributes).where(["username = :value OR email = :value", { :value => login }]).first}
        end

        def mongoid
          %q{where("function() {return this.username == '#{login}' || this.email == '#{login}'}").first}
        end  

        def mongo_mapper
          %q{where("function() {return this.username == '#{login}' || this.email == '#{login}'}").first}
        end  
      end
    end 
    
    module UserAuth
      class << self
        def active_record
          %q{
  # protected

  def self.find_for_database_authentication(conditions)
    login = conditions.delete(:login)
    where(conditions).where(["username = :value OR email = :value", { :value => login }]).first
  end
}
        end

        def mongoid
        %q{
  def self.find_for_database_authentication(conditions)
    login = conditions.delete(:login)
    self.any_of({ :username => value }, { :email => login }).first
  end
}
        end
      end
    end    
  end
end