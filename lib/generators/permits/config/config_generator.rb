require 'sugar-high/file'
require 'sugar-high/modules'
require 'cream'
require 'rails3_artifactor'
require 'logging_assist'

module Permits
  module Generators 
    class ConfigGenerator < Rails::Generators::Base
      extend Rails3::Assist::UseMacro
        
      desc "Configure Permits"

      # ORM to use
      class_option :orm,                :type => :string,   :default => 'active_record',  :desc => "ORM to use"

      class_option :logfile,            :type => :string,   :default => nil,              :desc => "Logfile location" 

      def configure_devise_users
        @user_helper = UserHelper.new user_generator
      
        devise_default_user if !has_model? :user
      
        # if User model is NOT configured with devise strategy
        Strategy.insert_devise_strategy :user, :defaults if !has_devise_user? :user
      
        devise_admin_user if admin_user?
      end

      protected

      def permits_gems
        gem 'cancan-permits'        
      end 

      def configure_permits
        logger.debug "Configure Permits"
        # Run permits generator to generate permit for each role
        rgen "permits --roles #{roles}"
      end           
    end
  end
end