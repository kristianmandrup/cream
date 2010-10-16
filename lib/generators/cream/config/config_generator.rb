require 'sugar-high/file'
require 'sugar-high/module'
require 'cream'
require 'rails3_artifactor'
require 'logging_assist'

module Cream
  module Generators
  end
end

require_all File.dirname(__FILE__) + '/modules'

module Cream::Generators 
  class ConfigGenerator < Rails::Generators::Base
    extend Rails3::Assist::UseMacro
        
    desc "Configures Devise and Users" 

    source_root File.dirname(__FILE__)

    # Role Strategy
    class_option  :strategy,          :type => :string,   :default => 'role_string',    :desc => "Role strategy to use"

    # Create Admin user
    class_option :admin_user,         :type => :boolean,  :default => false,            :desc => "Create admin user"  

    # Roles
    class_option :default_roles,      :type => :boolean,  :default => true,             :desc => "Create default roles :admin and :guest"
    class_option :roles,              :type => :array,    :default => [],               :desc => "Roles to create"

    # Permits
    class_option :permits,            :type => :boolean,  :default => true,             :desc => "Configure permits or not"

    # ORM to use
    class_option :orm,                :type => :string,   :default => 'active_record',  :desc => "ORM to use"

    class_option :logfile,            :type => :string,   :default => nil,              :desc => "Logfile location"

    class_option :app_config,         :type => :boolean,  :default => true,             :desc => "Make Rails app ready for Cream"
    class_option :cream_config,       :type => :boolean,  :default => true,             :desc => "Configure app with Cream"
    class_option :devise_config,      :type => :boolean,  :default => true,             :desc => "Configure app with Devise"
    class_option :devise_user_config, :type => :boolean,  :default => true,             :desc => "Configure app with Devise Users"
    class_option :cancan_config,      :type => :boolean,  :default => true,             :desc => "Configure app with CanCan"
    class_option :permits_config,     :type => :boolean,  :default => true,             :desc => "Configure app with Permits"
    class_option :roles_config,       :type => :boolean,  :default => true,             :desc => "Configure app with Roles"    

    def main_flow 
      configure_logger
      configure_gems       

      MODULES.each do |name|
        method = "configure_#{name}"
        send method if respond_to?(method) && options[:"#{name}_config"]
      end
    end

    # -----------------      
    protected

    # configure which helper modules (from /modules subfolder) to include in this Generator!!!
    
    MODULES = [:app, :devise, :devise_users, :cancan, :roles, :permits, :cream]

    includes Cream::Generators::Config, :helper, MODULES

    include Rails3::Assist::BasicLogger

    # using helpers from rails3_artifactor gem. 
    # A macro from rails3_assist loads appropriate modules into the class and makes various Rails 3 "mutation helper" methods available
    use_helpers :model, :controller, :permit, :application

    def configure_logger
      logger.add_logfile :logfile => logfile if logfile
      logger.debug 'main flow'
    end

    def configure_gems
      MODULES.each do |name|
        method = "#{name}_gems"
        send method if respond_to?(method) && options[:"#{name}_config"]
      end
      run "bundle install"
    end
  end
end