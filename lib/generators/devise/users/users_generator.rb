require 'sugar-high/file'
require 'sugar-high/module'
require 'cream'
require 'rails3_artifactor'
require 'logging_assist'

module Devise
  module Generators 
    class UsersGenerator < Rails::Generators::Base        
      desc "Configure Devise with Users"

      # Create Admin user
      class_option :admin_user,   :type => :boolean,  :default => false,            :desc => "Create admin user"  
      # ORM to use
      class_option :orm,          :type => :string,   :default => 'active_record',  :desc => "ORM to use"
      class_option :logfile,      :type => :string,   :default => nil,              :desc => "Logfile location" 
      class_option :gems,         :type => :boolean,  :default => false,            :desc => "Add gems to gemfile?"       
      
      def configure_devise_users      
      	logger.add_logfile :logfile => logfile if logfile
        logger.debug "Configure Devise Users"

        devise_gems if gems?
        devise_default_user if !has_model? :user
      
        # # if User model is NOT configured with devise strategy
        insert_devise_strategy :user, :defaults if !has_devise_user? :user
      
        devise_admin_user if admin_user?
      end

      protected

      extend Rails3::Assist::UseMacro
      include Rails3::Assist::BasicLogger  

      use_helpers :model

      def gems?
        options[:gems]        
      end

      def logfile
        options[:logfile]
      end

      def devise_gems
        gem 'devise'
        bundle_install # 'devise'
      end

      def bundle_install #*gems
        run "bundle install" # #{gems.jon(' ')}"
      end
    
      def devise_default_user
        create_devise_model :user
      end

      def devise_admin_user
        # if app does NOT have a Admin model
        create_admin_user if !has_model? :admin
      end

      def create_admin_user
        logger.debug 'create_admin_user'
        create_user_model :admin
        # remove any current inheritance
        remove_inheritance :admin

        # insert default devise Admin strategy
        insert_devise_strategy :admin, :defaults if has_model? :admin

        # and make Admin model inherit from User model 
        inherit_model :user => :admin
      end 

      # Helpers

      def admin_user?
        options[:admin_user]
      end

      def user_generator 
        active_record? ?  'devise' : "#{orm}:devise"
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
                      
      def create_user_model user = :user
        rgen "#{user_generator} #{user}"
      end  

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
      
      # Must be ORM specific!
      def create_devise_model user = :user
        rgen "#{user_generator} #{user}"
      end
    
      def remove_inheritance user
        File.remove_content_from model_file_name(user), :where => /<\s*ActiveRecord::Base/
      end  

      def inherit_model hash                 
        superclass    = hash.keys.first.to_s.camelize 
        subclass  = hash.values.first
        logger.debug "subclass: #{subclass}"
        logger.debug "superclass: #{superclass}"
        File.replace_content_from model_file_name(subclass), :where => /class Admin/, :with => "class Admin < #{superclass}"
      end

      def insert_devise_strategy model_name, *names
        names = devise_default_strategies if names.first == :defaults        
        namestr = names.map{|n| ":#{n}"}.join(', ')
        insert_into_model model_name do
          "devise #{namestr}"
        end
      end
    
      def devise_default_strategies
        [:database_authenticatable, :confirmable, :recoverable, :rememberable, :trackable, :validatable]
      end          

    end
  end
end