module Cream::Generators 
  module Config
    module Devise        

      def configure_devise
        if !has_model? :user
          # run devise generator to create User model
          create_devise_model :user
        end                           
        
        # if User model is NOT configured with devise strategy
        if !has_devise_strategy? :user
            insert_devise_strategy :user, :defaults
          end    
        end
        
        configure_admin_user if configure_admin_user?
      end

      def configure_admin_user        
        # if app does NOT have a Admin model
        if !has_model? :admin
          create_admin_user
        end
        if has_model? :admin
          # insert default devise Admin strategy    
          insert_devise_strategy :user, :defaults            
        end
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
        end
      end

      def init_devise
        execute 'devise_install'
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

      def create_admin_user
        logger.debug 'create_admin_user'      
        create_model :admin          
        # remove any current inheritance
        remove_inheritance :admin            
        # and make Admin model inherit from User model 
        inherit_model :user => :admin
      end 

      def remove_inheritance user
        File.remove_from model_file user, :content => /<\s*ActiveRecord::Base/
      end  

      def inherit_model hash                 
        subclass    = hash.keys.first
        superclass  = hash.values.first.to_s.camelize
        File.replace_content_from model_file subclass, :where => /class Admin/, :with => "class Admin < #{superclass}"
      end
      
      # Must be ORM specific!
      def create_devise_model user
        execute "rails g devise #{user}"
      end

      def create_user user
        execute "rails g model #{user}"
      end  
      
      def has_user? user
        return true if user == :admin && !admin_user?
        begin
          read_model(user) =~ /devise/
        rescue Exception => e
          logger.info "Exception for has_user? #{user}: #{e.message}"
          false
        end
      end          
    end
  end
end
