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
      class_option :admin_class,  :type => :string,   :default => nil,              :desc => "Admin class"

      class_option :user_class,   :type => :string,   :default => 'User',           :desc => "User class"

      # ORM to use
      class_option :orm,          :type => :string,   :default => 'active_record',  :desc => "ORM to use"
      class_option :roles,        :type => :array,    :default => [],               :desc => "Roles"
      class_option :logfile,      :type => :string,   :default => nil,              :desc => "Logfile location" 
      class_option :gems,         :type => :boolean,  :default => false,            :desc => "Add gems to gemfile?"       
      
      def configure_devise_users      
      	logger.add_logfile :logfile => logfile if logfile
        logger.debug "Configure Devise Users"

        devise_gems if gems?
        devise_default_user if !has_model? :user
      
        # # if User model is NOT configured with devise strategy
        insert_devise_strategy :user, :defaults if !has_devise_user? :user
      
        devise_user admin_user if admin_user?

        # create role specific user inheriting from base user for each role
        roles.each do |role|
          devise_user role if !has_model? role
        end
        
        routes_configure!
      end

      protected

      extend Rails3::Assist::UseMacro
      include Rails3::Assist::BasicLogger  

      use_helpers :model, :app, :special, :file

      def routes_configure!
        insert_into_routes do
          routes_for_roles
        end
      end

      def routes_for_roles
        note = %q{
  # customize controller action if needed to render individual registration form for each role    
  # Example:
  # match "/editors/sign_up" => "user_registrations#new_editor", :as => :editor_signup

  #  'user_registrations_controller.rb' with the action #new_editor
  # def new_editor
  #   build_resource({})
  # end
  # 
  # and the registration form in 'views/user_registrations/new_editor.html.erb'
  #
}        
        roles_routes = roles.each do |role|
          %Q{
  devise_for :#{role.pluralize}, :class_name => '#{role.classify}'
  as :#{role} do
    match "/#{role.pluralize}/sign_up" => "devise/registrations#new", :as => :#{role}_signup
  end
}
        end
        
        say %q{
  Customize controller action if needed to render individual registration form for each role
  Example:

  routes.rb
    match "/editors/sign_up" => "user_registrations#new_editor", :as => :editor_signup

  user_registrations_controller.rb
    def new_editor
      build_resource({})
    end
  
  Create the registration form for the editor user in 'views/user_registrations/new_editor.html.erb'  
}, :green
        
        note + roles_routes
      end

      def roles
        options[:roles]
      end

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
        create_user admin_class if !has_admin_model?
      end

      def create_user name
        logger.debug "create_user: #{name}"
        create_user_model admin_class
        # remove any current inheritance
        remove_inheritance admin_class

        # insert default devise Admin strategy
        insert_devise_strategy admin_class, :defaults if has_admin_model?

        # and make Admin model inherit from User model 
        inherit_model user_class => admin_class
      end 

      # Helpers

      def has_admin_model?
        has_model? admin_class
      end

      def user_class
        options[:user_class] || 'User'
      end

      def admin_class
        options[:admin_class]
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
                      
      def create_user_model
        rgen "#{user_generator} #{user_class}"
      end  

      def devise_users?
        has_devise_user?(user_class) && has_devise_user?(admin_class)
      end

      def is_admin? name
        name.to_s.underscore == admin_class
      end

      def admin_class_name
        admin_class.to_s.classify
      end

      def has_devise_user? user
        return true if is_admin?(user) && !admin_class
        begin
          read_model(user) =~ /devise/
        rescue Exception => e
          logger.info "Exception for #has_devise_user? #{user}: #{e.message}"
          false
        end
      end
      
      # Must be ORM specific!
      def create_devise_model user = 'User'
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
        File.replace_content_from model_file_name(subclass), :where => /class #{admin_class_name}/, :with => "class #{admin_class_name} < #{superclass}"
      end

      def insert_devise_strategy model_name, *names
        names = devise_strategies[:default] if names.first == :defaults
        names = devise_strategies[:admin] if names.first == :admin

        namestr = names.map{|n| ":#{n}"}.join(', ')
        insert_into_model model_name do
          "devise #{namestr}"
        end
      end
    
      def devise_strategies
        {
          :default  => [:database_authenticatable, :confirmable, :recoverable, :rememberable, :trackable, :validatable]
          :admin    => [:database_authenticatable, :confirmable, :recoverable, :rememberable, :trackable, :validatable]
        }
      end
      
    end
  end
end