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

      def devise_initializer 
        initializer_file(:devise)
      end

      def devise_initializer? 
        initializer_file?(:devise)
      end        
    
      def devise_install        
        if devise_initializer?
          logger.debug "initializers/devise.rb was found so devise:install will not be run"
          return 
        end
        logger.debug "initializers/devise.rb was NOT found so devise:install will now be run" 
        rgen 'devise:install'
      end        

      def bundle_install *gems
        run "bundle install #{gems.join(' ')}"
      end

      def add_gem name
        gem name if !has_gem? name
      end

      def devise_gems 
        logger.debug "Configuring devise gems for #{orm}"
        add_gem 'devise'

        orm_gem = nil
        # Devise ORM integration        
        case orm.to_sym
        when :mongoid
          say "Please configure Devise for Mongoid similar to Rails 3 example app: http://github.com/fortuity/rails3-mongoid-devise"
          add_gem 'mongoid'
          bundle_install
          rgen "mongoid:devise"
        when :mongo_mapper
          orm_gem = 'mm-devise'
          add_gem 'mm-devise'
        when :data_mapper
          orm_gem = 'dm-devise'
          add_gem 'dm-devise'
        when :couch_db
          orm_gem = 'devise_couch'
          add_gem 'devise_couch'
          say "Please note that Couch DB does not currently have a Roles implementation. Feel free to provide one."
          say "Look at Roles DataMapper (roles_data_mapper) for an example ;)"
        else
          say "Orm #{orm} is not currently supported by Cream. You are most welcome to provide a Cream adapter for that ORM ;)"
        end
        bundle_install 'devise', orm_gem
      end 

      def protection_configure! orm
        logger.debug "Configuring: devise authentication filter"
        ## Add Devise protection to Application controller:
        insert_into_controller :application do
          "before_filter :authenticate_user!"
        end
      end

      # inside 'config/initializers/devise.rb' change to:
      # require 'devise/orm/mongo_mapper'
      def orm_configure! orm
        return if orm == 'active_record'
        logger.debug "Configuring orm: [#{orm}]"
        if devise_initializer?
          orm_found = File.new(devise_initializer).read =~/devise\/orm\/w+/
          if orm_found
            File.replace_content_from initializer_file(:devise),  :where => /devise\/orm\/\w+/, :with =>  "devise/orm/#{orm}"
          else
            say "WARNING: devise/orm statement not found in devise.rb initializer", :yellow
          end
        else
          say "WARNING: initializer/devise.rb not found", :yellow
        end
      end
        
      def mailer_configure! orm
        logger.debug "Configuring: devise mailer"            
        insert_application_config "action_mailer.default_url_options = { :host => 'localhost:3000' }"
      end
    end
  end
end