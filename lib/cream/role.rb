module Cream
  class << self
    attr_accessor :available_roles  
  end
  
  module Role
    def self.available
      return Cream.available_roles if Cream.available_roles.present?
      return Cream.roles if Cream.roles.present?
      if defined? ::Role
        ::Role.all.map(&:name).to_symbols
      elsif defined? ::User
        ::User.roles.to_symbols
      else
        raise %q{Available roles could not be determined. Please do either of the following:\n
1) Create a Cream.setup block
2) Set Cream.available_roles explicitly
3) Create Role instances and ensure a call to Role.all returns them
4) Set User.roles explicitly
}          
      end
    end
  end
end