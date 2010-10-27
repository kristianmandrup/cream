module Cream
  mattr_accessor :roles
  @@roles = []
    
  def self.setup
    yield self
  end
end