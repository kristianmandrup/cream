require 'active_support/railtie'
require 'r3_plugin_toolbox'

require_all File.dirname(__FILE__) + '/after_init'

Rails3::Plugin::Extender.new do
  # extend action_controller with methods from some modules

  extend_rails :controller do
    extend_from_module Cream, :role
    extend_from_module Cream::Controller, :ability
    extend_from_module Cream::Helper, :role, :host, :action 
  end  

  # extend action_view with methods from some modules
  extend_rails :view do
    extend_from_module Cream::View, :role, :host, :user_action_menu
    extend_from_module Cream::Helper, :role, :action
    extend_from_module Cream::Controller, :ability
  end  
  
  after :initialize do    
    load File.dirname(__FILE__) + '/after_init/role_config.rb'

    if defined? Cream::UserControl
      ApplicationController.send :include, Cream::UserControl
      ApplicationController.send :include, Cream::Controller::Ability
    else
      puts "Cream::UserControl not defined!"
    end
  end
end

