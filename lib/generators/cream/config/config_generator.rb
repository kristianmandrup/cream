require 'sugar-high/file'
require 'sugar-high/modules'
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
    class_option  :strategy,       :type => :string,   :desc => "Role strategy to use",  
                  :default => 'role_string'

    # Create Admin user
    class_option :admin_user,     :type => :boolean,  :desc => "Create admin user",     
                 :default => false

    # Default roles
    class_option :default_roles,  :type => :boolean,  :desc => "Create default roles :admin and :guest",     
                 :default => true

    class_option :roles_config,  :type => :boolean,  :desc => "Configure roles or not",     
                 :default => true

    class_option :permission_config,  :type => :boolean,  :desc => "Configure permissions or not",     
                 :default => true

    class_option :roles,          :type => :array,    :desc => "Create default roles :admin and :guest",     
                 :default => []

    # ORM to use
    class_option :orm,            :type => :string,   :desc => "ORM to use",            
                 :default => 'active_record'

    class_option :logfile,        :type => :string,   :desc => "Logfile location",            
                 :default => nil

    def main_flow 
      configure_logger
      configure_gems       

      MODULES.each do |name|
        send :"configure_#{name}"
      end
    end

    # -----------------      
    protected

    MODULES = [:devise] #, :cancan, :roles, :permits, :cream]

    includes Cream::Generators::Config, :helper, MODULES #, :cancan, :roles, :permits, :cream
    include Rails::Assist::BasicLogging

    use_helpers :model, :controller, :permit

    def configure_logger
      logger.add_logfile :logfile => logfile
      logger.debug 'main flow'
    end

    def configure_gems
      MODULES.each do |name|
        send :"#{name}_gems"
      end
      run "bundle install"
    end
  end
end