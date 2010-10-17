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
      class_option :orm,     :type => :string,   :default => 'active_record',   :desc => "ORM to use"
      class_option :logfile, :type => :string,   :default => nil,               :desc => "Logfile location" 
      class_option :gems,    :type => :boolean,  :default => true,              :desc => "Add gems to gemfile?"       

      def configure_devise
      	logger.add_logfile :logfile => logfile if logfile	        
        devise_gems if gems?
		    devise_install
        [:orm, :mailer, :protection].each{|m| send(:"#{m}_configure!", orm) }
      end

      protected

      include Rails3::Assist::BasicLogger
      extend Rails3::Assist::UseMacro

      use_helpers :controller, :app, :special, :file

      def gems?
        options[:gems]        
      end

      def logfile
        options[:logfile]
      end

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
    
      def devise_install
        logger.debug "initializer_file? #{initializer_file?(:devise)}"
        return if initializer_file?(:devise) 
        rgen 'devise:install'
      end        

      def bundle_install
        run "bundle install"
      end

      def devise_gems 
        logger.debug 'devise_gems'
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
        # bundle_install
      end 

      def protection_configure! orm
        logger.debug "config protection"            
        ## Add Devise protection to Application controller:
        insert_into_controller :application do
          "before_filter :authenticate_user!"
        end
      end

      # inside 'config/initializers/devise.rb' change to:
      # require 'devise/orm/mongo_mapper'
      def orm_configure! orm
        return if orm == :active_record 
        logger.debug "config orm: #{orm}"
        found = File.read(initializer_file(:devise)) =~/devise\/orm\/w+/
        logger.debug "found?: #{found}"
        
        File.replace_content_from initializer_file(:devise),  :where => /devise\/orm\/\w+/, :with =>  "devise/orm/#{orm}"
      end
        
      def mailer_configure! orm
        logger.debug "config mailer"            
        insert_application_config "action_mailer.default_url_options = { :host => 'localhost:3000' }"
      end
    end
  end
end