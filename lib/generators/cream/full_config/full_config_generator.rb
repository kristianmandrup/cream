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
      class_option :user_class,       :type => :string,   :default => 'User',           :desc => "User class", :aliases => '-u'
      class_option :role_class,       :type => :string,   :default => 'Role',           :desc => "Role class", :aliases => '-rc'
      class_option :user_role_class,  :type => :string,   :default => 'UserRole',       :desc => "UserRole class", :aliases => '-urc'

      # Roles
      class_option :default_roles,  :type => :boolean,  :default => true,             :desc => "Create default roles :admin and :guest", :aliases => '-dr'
      class_option :roles,          :type => :array,    :default => [],               :desc => "Roles to create", :aliases => '-r'

      class_option :user_types,     :type => :array,    :default => ['Admin'],        :desc => "Devise Users to create that override the generic base User", :aliases => '-ut'

      # ORM to use
      class_option :orm,            :type => :string,   :default => 'active_record',  :desc => "ORM to use", :aliases => '-o'

      class_option :locales,        :type => :array,    :default => ['all'],          :desc => "List of locales - 'all' means ALL locales", :aliases => '-l'
      class_option :logfile,        :type => :string,   :default => nil,              :desc => "Logfile location", :aliases => '-lf'

      class_option :configure,      :type => :array,    :default => [],               :desc => "Finetune which generators to run: app, permits, roles, devise, cancan", , :aliases => '-c'
      class_option :gems,           :type => :boolean,  :default => true,             :desc => "Add gems to gemfile?", :aliases => '-g'
      class_option :migrations,     :type => :boolean,  :default => false,            :desc => "Auto-run database migrations?", :aliases => '-m'

      # Devise customize
      class_option :customize,   :type => :array,    :default => [],          :desc => "Which elements of devise to customize (customize generator)", :aliases => '-cust'
      
      class_option :user_name,   :type => :boolean,  :default => true,        :desc => "Add username as login option", :aliases => '-un'
      class_option :login_type,  :type => :string,   :default => 'generic',   :desc => "How to login: 'email', 'username', 'generic' (i.e 'username' or 'email')", :aliases => '-lt'

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
        cream_locales if locales
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
        return if orm != :active_record
        logger.debug "Running DB migrations"          
        execute "rake db:migrate"
      end

      def run_app
        rgen "cream:app --orm #{orm}"
      end

      def run_devise
        rgen "devise:config #{user_class} --orm #{orm}" # --user-types #{user_types}
        rgen "devise:users --orm #{orm} --roles #{roles_list} --user-types #{user_types} --no-gems"

        say("Devise credentials not customized since --customize option was not used to say so!", :green) if !customize_credentials?

        rgen "devise:customize #{user_class} --orm #{orm} --login-type #{login_type} #{user_name_option}" if customize_credentials?
      end

      def run_cancan
        rgen "cancan:config --orm #{orm} --no-gems"
      end

      def run_roles
        rgen "roles:config #{user_class} --orm #{orm} --roles #{roles_list} --strategy #{strategy}"
      end

      def run_permits
        rgen "permits:config --orm #{orm} --roles #{roles_list} --no-gems"
      end
      
      def cream_initializer
        create_initializer :cream do
  %Q{Cream.setup do |config|
  config.roles = #{sym_roles.inspect} 
  config.user_types = #{user_types_list}
end

require 'cream/configure/rails'
}      
        end
      end

      def customize_credentials?
        customize.include? 'credentials'
      end

      def customize
        options[:customize]
      end

      def login_type
        options[:login_type]
      end

      def username?
        options[:user_name]
      end

      def user_name_option
        " --user-name " if username?
      end

      def locales
        options[:locales]
      end

      def supported_locales
        [:en, :da]
      end

      def locales_to_generate
        supported_locales - locales
      end

      def cream_locales                               
        return if locales_to_generate.empty?
        logger.debug "Generate Cream locale files"
        locales_to_generate.each do |locale|
          src = File.expand_path "config/locales/cream.#{locale}.yml".path.up(5), __FILE__
          copy_file src, "config/locales/cream.#{locale}.yml"
        end
      end
      
      private

      def run_migrations?
        options[:migrations]
      end      
    end
  end
end

