module Cream::Generators 
  module Config
    module Devise        

      def configure_devise
        init_devise if init_devise?
        handle_devise_users
      end

      def devise_gems
        gem 'devise'

        # Devise ORM integration
        case orm.to_sym
        when :mongoid
          say "Configure Devise for Mongoid as demonstrated by the Rails 3 example app: http://github.com/fortuity/rails3-mongoid-devise"
        when :mongo_mapper
          gem 'mm-devise'
        when :data_mapper
          gem 'dm-devise'
        end
      end

      def init_devise        
        run 'devise_install'
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
      
      # Must be ORM specific!
      def create_user
         'rails g devise User'
      end

      def create_admin_user
        run 'rails g devise Admin' 
      end      
    end
  end
end
