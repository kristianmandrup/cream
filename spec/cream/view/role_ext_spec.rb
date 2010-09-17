require 'spec_helper'

require 'active_support'
require 'action_controller'
require 'action_view'
# require 'active_record'
# require 'action_mailer'
require 'active_support/railtie'
# require 'rails/all'

module Minimal
  class Application < Rails::Application
    config.active_support.deprecation = :log
  end
end

Rails.application = Minimal::Application

class User
end

describe "View extensions" do
  describe 'Role area functionality' do
    
    it "should extend Action View with various Roles helper methods" do
      after_init :view do
        :view.should be_extended_with AuthAssistant::View, :roles
        :view.should be_extended_with AuthAssistant::Helper, :role
      end

      User.stubs(:roles).returns [:admin, :guest]

      init_app_railties :minimal, :view
    end
  end
end