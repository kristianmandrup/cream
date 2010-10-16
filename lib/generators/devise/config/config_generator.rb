require 'sugar-high/file'
require 'sugar-high/module'
require 'cream'
require 'rails3_artifactor'
require 'logging_assist'

module Devise
  module Generators 
    class ConfigGenerator < Rails::Generators::Base        
      desc "Configure Devise"

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

      def configure_devise
      	logger.add_logfile :logfile => logfile if logfile	        
        
		    initialize!
        [Orm, Mailer, Protection].each{|m| m.configure! orm}
      end

      protected

      include Rails3::Assist::BasicLogger
      extend Rails3::Assist::UseMacro

      use_helpers :controller, :application

      def orm
        options[:orm]
      end

      # rails generate ...
      def rgen command
        execute "rails g #{command}"
      end        

      def execute command
        logger.debug command
        run command
      end        
    
      def initialize!
        rgen 'devise_install'        
      end

      def devise_gems
        gem 'devise'

        # Devise ORM integration
        case orm.to_sym
        when :mongoid
          say "Please configure Devise for Mongoid as similar to Rails 3 example app: http://github.com/fortuity/rails3-mongoid-devise"
        when :mongo_mapper
          gem 'mm-devise'
        when :data_mapper
          gem 'dm-devise'
        when :couch_db
          gem 'devise_couch'
          say "Please note that Couch DB does not currently have a Roles implementation. Feel free to provide one."
          say "Look at Roles DataMapper (roles_data_mapper) for an example ;)"
        else
          say "Orm #{orm} is not currently supported by Cream. You are most welcome to provide a Cream adapter for that ORM ;)"
        end
      end 

      module Protection
        def self.configure! orm
          ## Add Devise protection to Application controller:
          insert_into_controller :application do
            "before_filter :authenticate_user!"
          end
        end
      end

      module Orm
        # inside 'config/initializers/devise.rb' change to:
        # require 'devise/orm/mongo_mapper'
        def self.configure! orm
          File.replace_content_from initializer_file(:devise),  :where => /devise\/orm\/w+/, :content =>  "devise/orm/#{orm}"
        end
      end

      module Mailer
        def self.configure! orm
          insert_application_config "action_mailer.default_url_options = { :host => 'localhost:3000' }"
        end
      end
    end
  end
end