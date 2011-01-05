require 'sugar-high/file'
require 'sugar-high/module'
require 'cream'
require 'rails3_artifactor'
require 'logging_assist'
require 'generators/cream/helpers/all'

module Roles
  module Generators 
    class ConfigGenerator < Rails::Generators::Base        
      desc "Configure Roles"

      argument     :user_class,         :type => :string,   :default => 'User',     :desc => "User class name"

      # ORM to use
      class_option :orm,                :type => :string,   :default => 'active_record',    :desc => "ORM to use"
      class_option :strategy,           :type => :string,   :default => 'role_string',      :desc => "Roles strategy to use"
      class_option :roles,              :type => :array,    :default => ['guest', 'admin'], :desc => "Valid roles to use"

      class_option :role_class,         :type => :string, :aliases => "-rc",  :default => 'Role',     :desc => "Role class name", :optional => true
      class_option :user_role_class,    :type => :string, :aliases => "-urc", :default => 'UserRole', :desc => "User-Role (join table) class name", :optional => true

      class_option :logfile,            :type => :string,   :default => nil,                :desc => "Logfile location" 
      class_option :default_roles,      :type => :boolean,  :default => true,               :desc => "Create default roles :admin and :guest"
      class_option :gems,               :type => :boolean,  :default => true,               :desc => "Add gems to gemfile?"       
      
      def configure_roles
      	logger.add_logfile :logfile => logfile if logfile

        # make the artifactor model methods behave according to selected orm! - this is a macro
        set_orm      	

        roles_gems if gems?

        # run the orm specific Roles generator
        create_roles

        # setup User to use the roles registered with Cream
        set_valid_roles_cream                
      end      

      protected

      include Rails3::Assist::BasicLogger
      extend Rails3::Assist::UseMacro

      include Cream::GeneratorHelper::Orm
      include Cream::GeneratorHelper::Executor
      include Cream::GeneratorHelper::Args
      
      use_helpers :model, :file

      def roles_gems
        gem_name = "roles_#{orm}"
        add_gem gem_name
        bundle_install #gem_name
      end 

      def create_roles
        rgen "#{roles_generator} #{user_class} --strategy #{strategy} --roles #{roles_list} #{default_roles_option} #{class_options}"        
      end

      def set_valid_roles_cream
        user_exist_check

        if initializer_file? :cream
          if read_model(user_class) =~ /valid_roles_are/
            replace_in_model user_class, :where => /valid_roles_are\s+[(.*)]/, :with => cream_valid_roles_statement
          else            
            insert_into_model user_class do
              cream_valid_roles_statement
            end
          end
        else
          say "Missing initializer file for cream. Please run Cream config generator to create this initializer"
        end          
      end

      private

      def class_options
        option_str = ""                            
        if role_ref_strategy?
          option_str << " --role-class #{role_class}" 
          option_str << " --user-role-class #{user_role_class}" if relational_mapper?
        end
        option_str
      end

      def role_class
        options[:role_class] || 'Role'
      end

      def user_role_class
        options[:user_role_class] || 'UserRole'
      end


      def user_exist_check
        raise "ERROR: User model missing. Please create a User model before running this generator" if !has_user_model?
      end

      def roles_generator
        "#{orm}:roles"
      end

      def cream_valid_roles_statement
        "valid_roles_are Cream::Role.available"
      end

      def default_roles_option
        default_roles? ? '--default-roles' : '--no-default-roles'
      end      
    end
  end
end