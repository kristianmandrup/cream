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
      	if gems?
      	  devise_gems
    	  else
      	  say "WARNING: Not configuring devise gems for #{orm}", :yellow
    	  end
         
		    devise_install
        [:orm, :mailer, :protection].each{|m| send(:"#{m}_configure!", orm) }
      end

      protected

      include Rails3::Assist::BasicLogger
      extend Rails3::Assist::UseMacro

      use_helpers :controller, :app, :special, :file

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

      def devise_initializer_content 
        File.new(devise_initializer).read
      end
    
      def devise_install        
        if devise_initializer?
          logger.debug "initializers/devise.rb was found so devise:install will not be run"
          return 
        end
        logger.debug "initializers/devise.rb was NOT found so devise:install will now be run" 
        rgen 'devise:install'
      end        

      def bundle_install
        run "bundle install"
      end

      def gems_mongo_db
        add_gem 'bson_ext', '>= 1.1.4'
      end

      def is_active_record?
        [:ar, :active_record].include? orm.to_sym
      end

      def is_mongo_mapper?
        [:mm, :mongo_mapper].include? orm.to_sym
      end

      def is_data_mapper?
        [:dm, :data_mapper].include? orm.to_sym
      end
            
      def devise_gems 
        say "Configuring devise gems for #{orm}", :green
        add_gem 'devise'

        # Devise ORM integration        
        case orm.to_sym
        when is_active_record?
          say "Configuring for Active Record"
        when is_mongo_mapper?
          say "Configuring for Mongo Mapper"
          add_gem 'mm-devise'
          gems_mongo_db          
        when is_data_mapper?
          say "Configuring for Data Mapper"
          add_gem 'dm-devise'
        when :mongoid
          say "Configuring for Mongoid"
          say "Please configure Devise for Mongoid similar to Rails 3 example app: http://github.com/fortuity/rails3-mongoid-devise"
          add_gem 'mongoid', '>= 2.0.0.beta.20'
          gems_mongo_db
        when :couch_db
          say "Configuring for Couch DB"
          add_gem 'devise_couch'
          say "Please note that Couch DB does not currently have a complete Roles implementation. Please help implement strategies for this adapter."
        else
          say "Orm #{orm} is not currently supported by Cream. You are most welcome to provide a Cream adapter for that ORM ;)"
        end
        clean_gemfile
        
        bundle_install
        if orm.to_sym == :mongoid
          rgen 'mongoid:config'
          rgen "devise mongoid" 
        end
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
        
        if !devise_initializer?        
          say "WARNING: initializer/devise.rb not found", :yellow
          return
        end
          
        if !has_statement?(orm_replacement)
          logger.debug "require 'devise/orm/#{orm}' already in devise.rb initializer"
          return
        end

        if !has_devise_orm_statement?
          say "WARNING: devise/orm statement not found in devise.rb initializer", :yellow
          return
        end
        
        File.replace_content_from devise_initializer,  :where => orm_statement, :with => orm_replacement
      end
        
      def mailer_configure! orm
        logger.debug "Configuring: devise mailer"            
        insert_application_config "action_mailer.default_url_options = { :host => 'localhost:3000' }"
      end
      
      private
     
      def add_gem_version name, version
        if !has_gem_version?(name, version)
          logger.debug "Adding gem: #{name}, #{version}"
          gem name, :version => version
        else
          logger.debug "gem: #{name}, #{version} already in Gemfile"
        end        
      end

      def add_gem name, version = nil
        if version
          add_gem_version name, version 
          return 
        end
        
        if !has_gem? name
          logger.debug "Adding gem: #{name}"
          gem name
        else
          logger.debug "gem: #{name} already in Gemfile"          
        end
      end

      def gems?
        options[:gems]        
      end

      def logfile
        options[:logfile]
      end

      def orm
        options[:orm]
      end
      
      def has_devise_orm_statement?
        devise_initializer_content =~ orm_statement
      end

      def has_statement? statement
        devise_initializer_content =~ /#{Regexp.escape(statement)}/
      end

      def has_devise_orm_replacement?
        has_statement? orm_replacement
      end

      def orm_statement   
        /devise\/orm\/\w+/
      end

      def orm_replacement 
        "devise/orm/#{orm}"
      end      
    end
  end
end