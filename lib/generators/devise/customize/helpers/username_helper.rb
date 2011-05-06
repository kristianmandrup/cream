require 'generators/cream/helpers/all'

module Devise
  module Customizers
    class UserName 
      include Cream::GeneratorHelper        
      extend  RailsAssist::UseMacro
      
      use_helpers :app, :special, :file, :model

      attr_accessor :orm, :user_class, :login_attribute
  
      def initialize orm, user_class, login_attribute
        @orm = orm
        @user_class = user_class          
        @login_attribute = login_attribute
      end

      def add_to_user_class
        debug! 'add_to_user_class'
        if active_record? && !has_migration_file?(:add_username_to_users)
          debug! 'create migration: add_username_to_users'
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
        return if user_class_content? 'attr_accessible :username'

        ::File.insert_into model_file(user_class), :before_last => 'end' do
          %q{
  # accessor config
  attr_accessible :username}
        end
      end

      def add_virtual_login_accessor          
        return if user_class_content? 'attr_accessor :login' 
        
        ::File.insert_into model_file(user_class), :before_last => 'end' do
          %q{
  attr_accessor :login}
        end
      end

      def configure_generic_login
        debug! 'configure generic login'
        add_virtual_login_accessor        
        override_user_auth        
        modify_retrieve_password
      end

      def override_user_auth
        if !is_default_devise_orm?
          Devise::CustomizeMessage.find_record
          return
        end         

        return if user_class_content? '# self.find_for_database_authentication'
                
        ::File.insert_into model_file(user_class), :before_last => 'end' do
          ::Devise::QueryCustomizers::UserAuth.send orm
        end
      end

      def modify_retrieve_password
        if !is_default_devise_orm?
          ::Devise::CustomizeMessage.retrieve_password
          return
        end
        insert_reset_password_keys_stmt # in devise initializer

        return if user_class_content? '# recover login'
        
        content = recover_login_header << ::Devise::Customizers::RecoverLogin.new(orm).retrieve_password

        ::File.insert_into model_file(user_class), :before_last => 'end' do
          content
        end        
      end
      
      def insert_reset_password_keys_stmt
        return if devise_init_content? '# reset_password_keys = [ :login ]'        
        ::File.insert_into initializer_file(:devise), 'config.reset_password_keys = [ :login ]', :after => 'Rails::Application'
      end        

      protected

      def user_class_content? content
        read_model(user_class) =~ content.to_regexp
      end

      def devise_init_content? content
        read_initializer(:devise) =~ content.to_regexp
      end

      def recover_login_header
        %q{
  protected

  # recover login
}
      end

      class AuthenticationKeys
        include Cream::GeneratorHelper
        extend  RailsAssist::UseMacro
        
        use_helpers :app, :special, :file

        attr_accessor :login_attribute

        def initialize user_class, login_attribute
          @user_class = user_class          
          @login_attribute = login_attribute
        end

        def modify_initializer
          debug! 'modify devise initializer'
          return if devise_init_content? keys_stmt_replacement(login_attribute)
        
          replace_initializer_content :devise,  :where => default_keys_stmt, :with => keys_stmt_replacement(login_attribute)
        end

        def devise_init_content? content
          read_initializer(:devise) =~ content.to_regexp
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