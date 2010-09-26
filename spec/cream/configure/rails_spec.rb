require 'configure_helper'

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

describe "Rails extension" do
  describe 'View extension' do
    it "should extend Action View with Roles helper instance_methods and specific role methods" do
      after_init :view do
        :view.should be_extended_with Cream::View,    :role, :host, :user_action_menu
        :view.should be_extended_with Cream::Helper,  :role
        # [:admin, :guest].each do |role|
        #   view.should respond_to? :"for_#{role}"
        #   view.should respond_to? :"#{role}_area"
        #   view.should respond_to? :"#{role}?"
        # end
      end

      init_app_railties :minimal, :view
    end
  end
end
