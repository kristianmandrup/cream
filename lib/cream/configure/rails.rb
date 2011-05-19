require 'active_support/railtie'
require 'r3_plugin_toolbox'

require_all File.dirname(__FILE__) + '/after_init'

Rails3::Plugin::Extender.new do
  # extend action_controller with methods from some modules

  # helper modules:
  # - ability_ext, host_ext, language_ext, permit_ext, role_attributes_ext, role_ext, session_ext, user_ext

  extend_rails :controller do
    extend_from_module Cream, :role

    extend_from_module Cream::Helper, :role_ext,    :host_ext,    :permit_ext
    extend_from_module Cream::Helper, :ability_ext, :permit_ext,  :session_ext, :user_ext
  end  

  # extend action_view with methods from some modules
  extend_rails :view do
    extend_from_module Cream::View,   :role,        :host,        :user_action_menu

    extend_from_module Cream::Helper, :role_ext,    :permit_ext,  :ability_ext 
    extend_from_module Cream::Helper, :permit_ext,  :session_ext, :user_ext
  end  
  
  after :initialize do    
    load File.dirname(__FILE__) + '/after_init/role_config.rb'

    if defined? Cream::UserControl
      ApplicationController.send :include, Cream::Helper::UserExt
      ApplicationController.send :include, Cream::Helper::SessionExt
    else
      puts "Cream::UserControl not defined!"
    end
  end
end

