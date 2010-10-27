require 'sugar-high/file'
require 'sugar-high/module'
require 'cream'
require 'rails3_artifactor'
require 'logging_assist'

module Cream
  module Generators
    class FullConfigGenerator < ::Rails::Generators::Base
      desc "Configures a Rails 3 app with Cream" 

      # Role Strategy
      class_option  :strategy,      :type => :string,   :default => 'role_string',    :desc => "Role strategy to use"

      # Create Admin user
      class_option :admin_user,     :type => :boolean,  :default => false,            :desc => "Create admin user"  

      # Roles
      class_option :default_roles,  :type => :boolean,  :default => true,             :desc => "Create default roles :admin and :guest"
      class_option :roles,          :type => :array,    :default => [],               :desc => "Roles to create"

      # ORM to use
      class_option :orm,            :type => :string,   :default => 'active_record',  :desc => "ORM to use"

      class_option :logfile,        :type => :string,   :default => nil,              :desc => "Logfile location"

      class_option :configure,      :type => :array,    :default => [],               :desc => "Which generators to run"
      class_option :gems,           :type => :boolean,  :default => true,             :desc => "Add gems to gemfile?"       

      def main_flow             
        cream_initializer
        cream_gems if gems?
        run_generators      
      end

      # -----------------      
      protected

      include Rails3::Assist::BasicLogger
      extend Rails3::Assist::UseMacro

      use_helpers :app, :special, :file

      def logfile
        options[:logfile]
      end

      def gems?
        options[:gems]        
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

      def run_app
        rgen "cream:app --orm #{orm}"
      end

      def run_devise
        # rgen "devise:config --orm #{orm} --no-gems"
        rgen "devise:config --orm #{orm} --no-gems"
        rgen "devise:users --orm #{orm} #{admin_user_option} --no-gems"
      end

      def run_cancan
        rgen "cancan:config --orm #{orm} --no-gems"
      end

      def run_roles
        rgen "roles:config --orm #{orm} --roles #{roles.join(' ')} --strategy #{strategy} --no-gems"
      end

      def run_permits
        rgen "permits:config --orm #{orm} --roles #{roles.join(' ')} --no-gems"
      end

      def admin_user_option
        admin_user? ? '--admin-user' : ''
      end

      def strategy
        options[:strategy]
      end        

      def admin_user?
        options[:admin_user]
      end

      def orm
        options[:orm]
      end

      def default_roles?
        options[:default_roles]
      end

      def roles         
        defaults = default_roles? ? ['guest', 'admin'] : [] 
        options[:roles] + defaults
      end

      def sym_roles
        roles.map(&:to_sym)
      end

      # rails generate ...
      def rgen command
        execute "rails g #{command}"
      end        

      def execute command
        logger.debug command
        run command
      end

      def bundle_install
        run "bundle install"
      end

      def configures
        return [:app, :permits, :roles, :devise, :cancan] if options[:configure].empty? 
        options[:configure].map{|c| c.to_sym}
      end

      def cream_gems
        gem 'cream'
        # bundle_install
      end      

      def cream_initializer
        create_initializer :cream do         
  %Q{Cream.setup do |config|
    config.roles = #{sym_roles.inspect} 
  end}      
        end
      end

      def cream_locale
        src = File.expand_path "config/locales/en.yml".path.up(2)
        # src = "config/locales/en.yml"
        logger.debug "configure_locale, copy from: #{src}"            
        copy_file src, "config/locales/cream.en.yml"
      end
    end
  end
end

