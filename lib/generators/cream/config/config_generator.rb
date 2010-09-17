require 'sugar-high/file'
require 'cream'
require 'rails3_artifactor'
require 'logging_assist'

module Cream
  module Generators
  end
end

require 'generators/cream/config/helpers'

module Cream::Generators 
  class ConfigGenerator < Rails::Generators::Base
    extend Rails3::Assist::UseMacro
        
    desc "Configures Devise and Users" 

    source_root File.dirname(__FILE__)

    # Role Strategy
    class_option  :strategy,       :type => :string,   :desc => "Role strategy to use",  
                  :default => 'role_string'

    # Init Devise
    class_option :init_devise,    :type => :boolean,  :desc => "Initialize devise",     
                 :default => false 

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
      logger.add_logfile :logfile => logfile
      logger.debug 'main flow'
       
      init_devise if init_devise?
      configure_devise_gems
      handle_devise_users if !devise_users?

      if devise_users?     
        logger.debug 'Devise users OK'           
        configure_roles if roles_config?       
        configure_permission_system if permission_config?
        configure_locale
        handle_devise_users
      else
        logger.warn 'Devise users not there!'        
      end
    end

    # -----------------      
    protected

    # include Rails::Assist::BasicLogging

    def logger
      @log ||= Rails::Assist::Logging.new 
    end  

    use_helpers :model, :controller, :permit

    def init_devise        
      invoke 'devise_install'
    end

    ORM_MAP = {
      :data_mapper  => 'dm-devise',
      :mongo_mapper => 'mm-devise',
      :mongoid      => 'rails3-mongoid-devise'                
    }

    def configure_devise_gems
      gem_name = ORM_MAP[orm]      
      gem gem_name if gem_name
      gem "roles_#{orm}"
      gem 'devise'
      gem 'cancan'
      run "bundle install"
    end

    def devise_users?
      has_user?(:user) && has_user?(:admin)
    end

    def handle_devise_users
      return notify_create_users if !init_devise?
      create_users 
    end

    def notify_create_users
      logger.debug 'notify_create_users'
      say "You must first run devise generators:"
      say "rails g devise User"
      say "rails g devise Admin" if admin_user?      
    end

    def create_users
      logger.debug 'create_users'      
      run "rails g devise User"
      if user_admin?
        logger.debug 'create devise Admin user'              
        run "rails g model Admin"
        File.replace_content_from model_file(:admin), where => /Admin/, with => 'Admin < User'
      end
    end

    def configure_roles
      command = "rails g #{orm}:roles --strategy #{strategy} --roles #{roles} #{default_roles}"
      logger.debug command
      run command
    end

    def configure_permission_system
      logger.debug "configure_permission_system"
      configure_exception_handling
    end

    def configure_locale
      src = File.expand_path "config/locales/en.yml".path.up(2)
      # src = "config/locales/en.yml"
      logger.debug "configure_locale, copy from: #{src}"            
      copy_file src, "config/locales/cream.en.yml"
    end

    # -----------------
    private

    # Must be ORM specific!
    def create_user
       'rails g devise User'
    end

    def create_admin_user
      run 'rails g devise Admin' 
    end      

    # CanCan permissions configuration
    def configure_exception_handling         
      insert_into_controller :application, :after => "ActionController::Base\n" do
        %{
rescue_from CanCan::AccessDenied do |exception|
  flash[:error] = exception.message
  redirect_to root_url
end
}
      end
    end

    include Helpers
  end
end