require 'generators/cream/helpers/all'

module Devise
  module Customizers
    class UserName 
      include Cream::GeneratorHelper        
      extend Rails3::Assist::UseMacro
      include Rails3::Assist::BasicLogger      
      use_helpers :app, :special, :file, :model
      # include Devise::UserCustomization      

      attr_accessor :orm, :user_class, :login_attribute
  
      def initialize orm, user_class, login_attribute
        @orm = orm
        @user_class = user_class          
        @login_attribute = login_attribute
      end

      def add_to_user_class
        logger.debug 'add_to_user_class'
        if active_record?
          logger.debug 'add migration: username'
          %x[rails g migration add_username_to_users username:string]
          %x[rake db:migrate]        
        end

        make_attribute_accessible                
        
        AuthenticationKeys.new(user_class, login_attribute).modify_initializer 

        if login_attribute == 'login'
          configure_generic_login
          ::Devise::CustomizeMessage.locales_update
        end
      end

      def make_attribute_accessible
        insert_into_model user_class do
          'attr_accessible :username'
        end
      end

      def add_virtual_login_accessor
        insert_into_model user_class do
          'attr_accessor :login'
        end
      end      

      def configure_generic_login
        logger.debug 'configure generic login'
        override_user_auth
        add_virtual_login_accessor
        modify_retrieve_password
      end

      def override_user_auth
        if !is_default_devise_orm?
          Devise::CustomizeMessage.find_record
          return
        end
        insert_into_model user_class do
          ::Devise::QueryCustomizers::UserAuth.send orm
        end
      end

      def modify_retrieve_password
        if !is_default_devise_orm?
          ::Devise::CustomizeMessage.retrieve_password
          return
        end
        insert_reset_password_keys_stmt # in devise initializer
        content = "protected\n" << ::Devise::Customizers::RecoverLogin.new(orm).retrieve_password
        
        ::File.insert_into model_file(user_class), :before_last => 'end' do
          content
        end        
      end
      
      def insert_reset_password_keys_stmt
        ::File.insert_into initializer_file(:devise), 'config.reset_password_keys = [ :login ]', :after => 'Rails::Application'
      end        

      protected

      class AuthenticationKeys
        include Cream::GeneratorHelper
        extend Rails3::Assist::UseMacro
        include Rails3::Assist::BasicLogger
        use_helpers :app, :special, :file

        attr_accessor :login_attribute

        def initialize user_class, login_attribute
          @user_class = user_class          
          @login_attribute = login_attribute
        end

        def modify_initializer
          logger.debug 'modify devise initializer'
          replace_initializer_content :devise,  :where => default_keys_stmt, :with => keys_stmt_replacement(login_attribute)
        end

        def keys_stmt_replacement name
          "config.authentication_keys = [ :#{name} ]"
        end

        def default_keys_stmt
          /# config.authentication_keys = [\s*:email\s*]/
        end
      end
    end
  end
end