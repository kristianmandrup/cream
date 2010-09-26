require 'rspec/core'
require 'r3_plugin_toolbox'
require 'cream'
require 'action_controller'
require 'action_view'
require 'active_support/railtie'

module Minimal
  class Application < Rails::Application
    config.active_support.deprecation = :log
  end
end

RSpec.configure do |config|
  config.mock_with :mocha 
end

