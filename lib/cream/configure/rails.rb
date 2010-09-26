require 'active_support/railtie'
require 'r3_plugin_toolbox'

Rails3::Plugin::Extender.new do
  # extend action_controller with methods from some modules

  extend_rails :controller do
    extend_from_module Cream, :role
    extend_from_module Cream::Controller, :ability
    extend_from_module Cream::Helper, :role, :local_host, :auth_label
    extend_from_module Cream::Link, :session, :registration, :rest, :session          
  end  

  # extend action_view with methods from some modules
  extend_rails :view do
    extend_from_module Cream::View, :role, :host, :user_action_menu
    extend_from_module Cream::Helper, :role, :auth_label
  end  
  
  after :initialize do   
    puts "Rails app initialized"
    require_all File.dirname(__FILE__) + '/after_init'
  end
end
