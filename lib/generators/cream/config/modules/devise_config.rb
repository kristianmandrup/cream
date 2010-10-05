module Cream::Generators 
  module Config
    module Devise        

      def configure_devise        
        initialize!
        [Orm, Mailer, Protection].each{|m| m.configure!}
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
        def self.configure!
          ## Add Devise protection to Application controller:
          insert_into_controller :application do
            "before_filter :authenticate_user!"
          end
        end
      end

      module Orm
        # inside 'config/initializers/devise.rb' change to:
        # require 'devise/orm/mongo_mapper'
        def self.configure!
          File.replace_content_from initializer_file(:devise),  :where => /devise\/orm\/w+/, :content =>  'devise/orm/mongo_mapper'
        end
      end

      module Mailer
        def self.configure!
          insert_application_config "action_mailer.default_url_options = { :host => 'localhost:3000' }"
        end
      end      
    end
  end
end
