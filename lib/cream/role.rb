module Cream
  class << self
    attr_accessor :available_roles
    attr_accessor :available_user_types
  end

  module UserTypes
    def self.available
      return Cream.available_user_types if Cream.available_user_types.present?
      return Cream.user_types if Cream.user_types.present?
      puts "Cream has not been configured with any devise User Types"
      []
    end
  
  module Role
    def self.available
      return Cream.available_roles if Cream.available_roles.present?
      return Cream.roles if Cream.roles.present?

      puts "Cream didn't have available roles configured, now trying alternatives: User and Role"

      return try_role if try_role
      return try_user if try_user
            
      raise %q{Available roles could not be determined. Please do either of the following:\n
1) Create a Cream.setup block
2) Set Cream.available_roles explicitly
3) Create Role instances and ensure a call to Role.all returns them
4) Set User.roles explicitly
}          
    end

    protected

    def self.try_user 
      if !defined? ::User
        puts "No User defined"
        return nil 
      end

      puts "User has roles available?"       
      return ::User.roles.to_symbols if ::User.respond_to?(:roles)             
      puts "User didn't have a #roles class method"
      nil
    end

    def self.try_role
      if !defined? ::Role
        puts "No Role defined"
        return nil 
      end

      puts "Role has roles available?"       
      return ::Role.all.map(&:name).to_symbols if ::Role.respond_to?(:all)        
      puts "Role didn't have an #all class method"
      nil
    end      
  end
end