require 'sugar-high/file'
require 'sugar-high/module'
require 'cream'
require 'rails3_artifactor'
require 'logging_assist'
require 'active_support'
require 'generators/cream/helpers/all'

module Cream
  module Generators
    class FullConfigGenerator < ::Rails::Generators::Base
      desc "Configures a Rails 3 app with Cream" 

      # Role Strategy
      class_option  :strategy,      :type => :string,   :default => 'role_string',    :desc => "Role strategy to use"

      # Create Admin user
      class_option :user_class,       :type => :string,   :default => 'User',           :desc => "User class"
      class_option :admin_class,      :type => :string,   :default => nil,              :desc => "Admin user class"
      class_option :role_class,       :type => :string,   :default => 'Role',           :desc => "Role class"
      class_option :user_role_class,  :type => :string,   :default => 'UserRole',       :desc => "UserRole class"

      # Roles
      class_option :default_roles,  :type => :boolean,  :default => true,             :desc => "Create default roles :admin and :guest"
      class_option :roles,          :type => :array,    :default => [],               :desc => "Roles to create"

      # ORM to use
      class_option :orm,            :type => :string,   :default => 'active_record',  :desc => "ORM to use"

      class_option :logfile,        :type => :string,   :default => nil,              :desc => "Logfile location"

      class_option :configure,      :type => :array,    :default => [],               :desc => "Finetune which generators to run: app, permits, roles, devise, cancan"
      class_option :gems,           :type => :boolean,  :default => true,             :desc => "Add gems to gemfile?"       
      class_option :migrations,     :type => :boolean,  :default => false,            :desc => "Autorun database migrations?", :aliases => '-m'

      def main 
        execute_generator if validate_orm && validate_strategy
      end

      # -----------------
      protected

      include Rails3::Assist::BasicLogger
      extend Rails3::Assist::UseMacro

      include Cream::GeneratorHelper

      use_helpers :app, :special, :file

      def execute_generator
        cream_initializer
        run_generators
        run_migrations if run_migrations?
      end

      # use this to define which part of the app this generator should configure (which sub-generators to run!)
      def configures
        return default_configures if options[:configure].empty? 
        options[:configure].map{|c| c.to_sym}
      end      
      
      def default_configures
        [:app, :permits, :roles, :devise, :cancan]
      end

      def run_generators
        # after setting up all gems so other generators are available
        # run those generators to do the heavy lifting!
        run_app if configures.include? :app      
        run_devise if configures.include? :devise
        run_cancan if configures.include? :cancan 
        run_roles if configures.include? :roles
        run_permits if configures.include? :permits
      end

      def run_migrations
        return if orm != 'active_record'
        execute "rake db:migrate"
      end

      def run_app
        rgen "cream:app --orm #{orm}"
      end

      def run_devise
        rgen "devise:config #{user_class} --orm #{orm} #{admin_user_option}"
        rgen "devise:users --orm #{orm} --roles #{roles_list} #{admin_user_option} --no-gems"
      end

      def run_cancan
        rgen "cancan:config --orm #{orm} --no-gems"
      end

      def run_roles
        rgen "roles:config --orm #{orm} --roles #{roles_list} --strategy #{strategy}"
      end

      def run_permits
        rgen "permits:config --orm #{orm} --roles #{roles_list} --no-gems"
      end
      
      def cream_initializer
        create_initializer :cream do         
  %Q{Cream.setup do |config|
  config.roles = #{sym_roles.inspect} 
end}      
        end
      end

      def cream_locale
        src = File.expand_path "config/locales/cream.en.yml".path.up(2)
        # src = "config/locales/en.yml"
        logger.debug "configure_locale, copy from: #{src}"            
        copy_file src, "config/locales/cream.en.yml"
      end
      
      private

      def run_migrations?
        options[:migrations]
      end
      
    end
  end
end

