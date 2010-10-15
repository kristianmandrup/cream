require 'active_support/railtie'
require 'r3_plugin_toolbox'

Rails3::Plugin::Extender.new do
  # extend action_controller with methods from some modules

  extend_rails :controller do
    extend_from_module Cream, :role
    extend_from_module Cream::Controller, :ability
    extend_from_module Cream::Helper, :role, :host, :auth_label
  end  

  # extend action_view with methods from some modules
  extend_rails :view do
    extend_from_module Cream::View, :role, :host, :user_action_menu
    extend_from_module Cream::Helper, :role, :auth_label
  end  

  before :initialize do
    ActiveSupport::Dependencies.autoload_paths += %W(#{Rails.root}/app/permits)
  end
  
  after :initialize do   
    require_all File.dirname(__FILE__) + '/after_init'

    # Rails3.with_configuration do
    #   autoload_paths += %W(#{Rails.root}/app/permits) 
    #    load_paths += %W( #{RAILS_ROOT}/extras ) 
    # end


    # set cream config object
    # Rails3.with_configuration do
    #   cream = Cream::Rails::Config.new :roles => Cream::Role.available
    # end
  end  
end
