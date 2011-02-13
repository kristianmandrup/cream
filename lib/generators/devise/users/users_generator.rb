require 'sugar-high/file'
require 'sugar-high/module'
require 'cream'
require 'rails3_artifactor'
require 'logging_assist'
require 'generators/cream/helpers/all'

# include helpers
require_all File.dirname(__FILE__)

module Devise
  module Generators 
    class UsersGenerator < Rails::Generators::Base        
      desc "Configure Devise with Users"

      # Create Admin user
      class_option :admin_class,    :type => :string,   :default => nil,              :desc => "Admin class"

      class_option :user_class,     :type => :string,   :default => 'User',           :desc => "User class"

      class_option :registrations_for,  :type => :array,   :default => [],            :desc => "User types individual registrations"

      # ORM to use
      class_option :orm,            :type => :string,   :default => 'active_record',  :desc => "ORM to use"
      class_option :roles,          :type => :array,    :default => [],               :desc => "Roles"
      class_option :default_roles,  :type => :boolean,  :default => true,             :desc => "Create default roles :admin and :guest"

      class_option :user_types,     :type => :array,    :default => ['admin'],        :desc => "Devise Users to create that override the generic base User", :aliases => '-ut'

      class_option :logfile,        :type => :string,   :default => nil,              :desc => "Logfile location" 
      class_option :gems,           :type => :boolean,  :default => false,            :desc => "Add gems to gemfile?"
      
      def configure_devise_users      
      	logger.add_logfile :logfile => logfile if logfile
        logger.debug "Configure Devise Users"

        self.class.use_orm orm.to_sym

        devise_gems if gems?

        # create user model with devise strategies if user model doesn't already exist  
        devise_base_user if !has_user_model?
      
        # # if User model is NOT configured with devise strategy
        insert_devise_strategy user_class, :defaults if !has_devise_user? user_class
      
        # create role specific user inheriting from base User for each role
        user_types.flatten.each do |user_type|
          create_user(user_type) if !has_model?(user_type.as_filename)
        end
        
        routes_configure!
        
        registrations.each do |reg|
          if user_type? reg
          # create controller   
          controller = "#{reg}::Registrations".camelcase
          rgen "controller #{controller} new"
          rgen "view #{controller} new"
          
          # make controller a devise controller
          replace_controller_inheritance controller.underscore, 'Devise::RegistrationsController' 
        end
      end

      protected

      extend Rails3::Assist::UseMacro
      include Rails3::Assist::BasicLogger  

      include Cream::GeneratorHelper
      
      include DeviseUserGenerator::Helper
      include DeviseUserGenerator::RoutesHelper

      use_helpers :model, :app, :special, :file

      def remove_controller_inheritance name
        File.remove_content_from controller_file_name(name.as_filename), :where => /<\s*ApplicationController/
      end

      def replace_controller_inheritance name, replace_controller  
        File.replace_content_from controller_file_name(name.as_filename), :where => /<\s*ApplicationController/, :with => replace_controller
      end

      def registrations
        options[:registrations_for]
      end

      # creates a new user model of a given name without devise strategies, instead inheriting from the base User
      # Never create a Guest user model as this should always be a "fake" (suggestions!?) 
      def create_user name
        return if name.to_sym == :guest

        logger.debug "create devise user: #{name}"
        create_user_model name
        # remove any current inheritance
        remove_inheritance name

        # and make Admin model inherit from User model 
        inherit_model name => user_class
      end 
    
      def insert_devise_strategy model_name, *names
        insert_into_model model_name do
          "devise #{name_string names}"
        end
      end

      def name_string names
        names = devise_strategies[:default] if names.first == :defaults
        names = devise_strategies[:admin] if names.first == :admin

        names.map{|n| ":#{n}"}.join(', ')
      end

      # Must be ORM specific!
      def create_devise_model user = 'User'
        rgen "#{user_generator} #{user}"
      end

      def devise_gems
        gem 'devise'
        bundle_install # 'devise'
      end
    
      def devise_base_user
        create_devise_model user_class
      end

      private

      def customize_note
        %q{
Customize controller action if needed to render an individual registration form for each devise User type

Example:

- routes.rb:

  match "/editors/sign_up" => "user_registrations#new_editor", :as => :editor_signup

- user_registrations_controller.rb:

  def new_editor
    build_resource({})
  end

Then create the registration form (view) for the :editor user in 'views/user_registrations/new_editor.html.erb'  
See comments in routes.rb for more info. There is also a page on the wiki about advanced routes customization.
}
      end
      
    end
  end
end