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
    class_option  :strategy,          :type => :string,   :default => 'role_string',    :desc => "Role strategy to use", 

    # Create Admin user
    class_option :admin_user,         :type => :boolean,  :default => false,            :desc => "Create admin user",  

    # Roles
    class_option :default_roles,      :type => :boolean,  :default => true,             :desc => "Create default roles :admin and :guest"
    class_option :roles,              :type => :array,    :default => [],               :desc => "Roles to create"

    # Permits
    class_option :permits,            :type => :boolean,  :default => true,             :desc => "Configure permits or not"

    # ORM to use
    class_option :orm,                :type => :string,   :default => 'active_record',  :desc => "ORM to use"

    class_option :logfile,            :type => :string,   :default => nil,              :desc => "Logfile location"

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

    include Rails3::Assist::BasicLogger

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