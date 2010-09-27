require 'require_all'
require 'cream/namespaces'
require 'cream/configure/rails'

module Cream
  mattr_accessor :roles
  @@roles = []
    
  def self.setup
    yield self
  end
end