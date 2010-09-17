require 'spec_helper'
require 'r3_plugin_toolbox'

require 'active_support'
require 'action_controller'
require 'action_view'
require 'active_support/railtie'

module Minimal
  class Application < Rails::Application
    config.active_support.deprecation = :log
  end
end

class Role  
  attr_accessor :name
  
  def initialize name
    self.name = name
  end
  
  def self.all
    [Role.new('admin'), Role.new('guest')]
  end
end

require 'cream/role'
require 'cream/configure'

Rails.application = Minimal::Application

Minimal::Application.initialize!

describe "Rails extension" do
  describe 'View extension' do
    it "should extend Action View with Roles helper instance_methods and specific role methods" do
      extend Rails3::Plugin::Extender::Macro
  
      after_init :view do |view|
        view.should be_extended_with Cream::View, :roles, :area, :user_action_menu
        [:admin, :guest].each do |role|
          view.should respond_to? :"for_#{role}"
          view.should respond_to? :"#{role}_area"
          view.should respond_to? :"#{role}?"
        end
      end

      Minimal::Application.initialize!
    end    
  end
end