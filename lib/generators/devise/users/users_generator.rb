require 'sugar-high/file'
require 'sugar-high/modules'
require 'cream'
require 'rails3_artifactor'
require 'logging_assist'

module Devise
  module Generators 
    class UsersGenerator < Rails::Generators::Base        
      desc "Configure Devise with Users"

      # Create Admin user
      class_option :admin_user,         :type => :boolean,  :default => false,            :desc => "Create admin user"  

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

      protected

      extend Rails3::Assist::UseMacro
      include Rails3::Assist::BasicLogger
    
      attr_accessor :user_helper
    
      def devise_default_user
        user_helper.create_devise_model :user
      end

      def devise_admin_user
        # if app does NOT have a Admin model
        user_helper.create_admin_user if !has_model? :admin

        # insert default devise Admin strategy
        Strategy.insert_devise_strategy :admin, :defaults if has_model? :admin
      end

      def create_admin_user
        logger.debug 'create_admin_user'
        user_helper.create_user_model :admin
        # remove any current inheritance
        Inherit.remove_inheritance :admin
        # and make Admin model inherit from User model 
        Inherit.inherit_model :user => :admin
      end 

      # Helpers

      def admin_user?
        options[:admin_user]
      end

      def user_generator 
        active_record? ? "#{orm}:devise" : 'devise'
      end

      def active_record? 
        orm == 'active_record'
      end

      # rails generate ...
      def rgen command
        execute "rails g #{command}"
      end        

      def execute command
        logger.debug command
        run command
      end        

      def orm
        options[:orm]
      end
            
      class UserHelper 
        extend Rails3::Assist::UseMacro
        user_helpers :model
        
        attr_accessor :user_generator
      
        def initialize user_gen
          @user_generator = user_gen
        end
      
        def create_user_model user = :user
          rgen "#{user_generator} model #{user}"
        end  

        module DeviseUser

          def devise_users?
            has_devise_user?(:user) && has_devise_user?(:admin)
          end

          def has_devise_user? user
            return true if user == :admin && !admin_user?
            begin
              read_model(user) =~ /devise/
            rescue Exception => e
              logger.info "Exception for #has_devise_user? #{user}: #{e.message}"
              false
            end
          end
        end
        
        include DeviseUser
        
        # Must be ORM specific!
        def create_devise_model user = :user
          rgen "#{user_generator} #{user}"
        end
      end   

      include UserHelper::DeviseUser
    
      module Inherit 
        self << class        
          extend Rails3::Assist::UseMacro        
          use_helpers :model

          def remove_inheritance user
            File.remove_from model_file user, :content => /<\s*ActiveRecord::Base/
          end  

          def inherit_model hash                 
            subclass    = hash.keys.first
            superclass  = hash.values.first.to_s.camelize
            File.replace_content_from model_file subclass, :where => /class Admin/, :with => "class Admin < #{superclass}"
          end
        end
      end
    
      module Strategy
        self << class
          extend Rails3::Assist::UseMacro        
          use_helpers :model

          def insert_devise_strategy model_name, *names
            names = devise_default_strategies if names.first == :defaults        
            insert_into_model model_name do
              "devise #{*names}"
            end
          end
        
          def devise_default_strategies
            [:database_authenticatable, :confirmable, :recoverable, :rememberable, :trackable, :validatable]
          end          
        end      
      end    
    end
  end
end