require 'sugar-high/file'
require 'sugar-high/module'
require 'cream'
require 'rails3_artifactor'
require 'logging_assist'

module Roles
  module Generators 
    class ConfigGenerator < Rails::Generators::Base        
      desc "Configure Roles"

      # ORM to use
      class_option :orm,                :type => :string,   :default => 'active_record',    :desc => "ORM to use"
      class_option :strategy,           :type => :string,   :default => 'role_string',      :desc => "Roles strategy to use"
      class_option :roles,              :type => :array,    :default => ['guest', 'admin'], :desc => "Valid roles to use"
      class_option :logfile,            :type => :string,   :default => nil,                :desc => "Logfile location" 
      class_option :default_roles,      :type => :boolean,  :default => true,               :desc => "Create default roles :admin and :guest"
      class_option :gems,               :type => :boolean,  :default => true,              :desc => "Add gems to gemfile?"       
      
      def configure_roles
      	logger.add_logfile :logfile => logfile if logfile

        # make the artifactor model methods behave according to selected orm! - this is a macro
      	self.class.use_orm :"#{orm}"

        roles_gems if gems?
        create_roles
        use_roles_strategy
        set_valid_roles_cream                
      end      

      protected

      include Rails3::Assist::BasicLogger
      extend Rails3::Assist::UseMacro
      
      use_helpers :model, :file

      def gems?
        options[:gems]        
      end

      def logfile
        options[:logfile]
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

      def strategy
        options[:strategy]
      end

      def roles
        options[:roles].join(' ')
      end

      def default_roles?
        options[:default_roles]
      end

      def add_gem name
        gem name if !has_gem? name
      end

      def roles_gems
        gem_name = "roles_#{orm}"
        add_gem gem_name
        bundle_install #gem_name
      end 

      def bundle_install #*gems
        run "bundle install"  #{gems.join(' ')}
      end

      def roles_generator
        "#{orm}:roles"
      end

      def create_roles
        rgen "#{roles_generator} User --strategy #{strategy} --roles #{roles} #{default_roles}"        
      end

      def set_valid_roles_cream
        user_exist?
        if initializer_file? :cream
          if read_model(:user) =~ /valid_roles_are/
            replace_in_model :user, :where => /valid_roles_are\s+[(.*)]/, :with => 'valid_roles_are Cream.roles'
          else            
            insert_into_model :user do
              "valid_roles_are Cream::Role.available"
            end
          end
        else
          say "Missing initializer file for cream. Please run Cream config generator to create this initializer"
        end          
      end

      def user_exist?
        raise "User model missing. Please create a User model before running this generator" if !model_file?(:user)
      end

      def use_roles_strategy
        # user_exist?        
        
        # unless read_model(:user) =~ /use_roles_strategy/
        #   inject_into_file model_file(:user), "use_roles_strategy :#{strategy}\n\n", :before => "class"
        # end        
      end

      def default_roles
        default_roles? ? '--default-roles' : '--no-default-roles'
      end      
    end
  end
end