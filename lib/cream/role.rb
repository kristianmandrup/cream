module Cream
  class << self
    attr_accessor :available_roles  
  end
  
  module Role
    def self.available
      return Cream.available_roles if Cream.available_roles.present?
      if defined? ::Role
        ::Role.all.map(&:name).to_symbols
      else
        User.roles.to_symbols
      end
    end
  end
end