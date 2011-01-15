module Cream
  mattr_accessor :roles, :user_types
  @@roles = []
  @@user_types = []
    
  def self.setup
    yield self
  end
end