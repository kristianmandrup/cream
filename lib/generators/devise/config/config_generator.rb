require 'sugar-high/file'
require 'sugar-high/module'
require 'cream'
require 'rails3_artifactor'
require 'logging_assist'
require 'generators/cream/helpers/all'

# include helpers
require_all File.dirname(__FILE__)

module Devise
  module Generators 
    class ConfigGenerator < Rails::Generators::Base        
      desc "Configure Devise"

      argument :user_class,   :type => :string,  :default => 'User', :desc => "User class"

      # ORM to use
      class_option :orm,          :type => :string,   :default => 'active_record',   :desc => "ORM to use"
      class_option :logfile,      :type => :string,   :default => nil,               :desc => "Logfile location" 
      class_option :gems,         :type => :boolean,  :default => true,              :desc => "Add gems to gemfile?"
      class_option :admin_user,   :type => :boolean,  :default => false,             :desc => "Setup for admin user"

      def configure_devise
      	logger.add_logfile :logfile => logfile if logfile	        
      	devise_gems if gems?      	  
      	say "WARNING: Not configuring devise gems for #{orm}", :yellow if !gems?
         
		    devise_install 
		    configure_devise!
      end

      protected

      include Rails3::Assist::BasicLogger
      extend Rails3::Assist::UseMacro

      include Cream::GeneratorHelper

      use_helpers :controller, :app, :special, :file

      include DeviseConfigGenerator::AppHelper
      include DeviseConfigGenerator::GemHelper
    
      def devise_install        
        if devise_initializer?
          logger.debug "initializers/devise.rb was found so devise:install will not be run"
          return 
        end
        logger.debug "initializers/devise.rb was NOT found so devise:install will now be run" 
        rgen 'devise:install'
      end        

      # see app_helper.rb
      def configure_devise!
        [:orm, :mailer, :protection].each{|m| send(:"#{m}_configure!") }  
      end
            
      def devise_gems 
        say "Configuring devise gems for orm: #{orm}", :green
        add_gem 'devise'

        send :"configure_gems_#{orm}" # see gem_helper.rb
        
        clean_gemfile
        
        bundle_install
        devise_mongoid_setup if mongoid?
      end       
    end
  end
end