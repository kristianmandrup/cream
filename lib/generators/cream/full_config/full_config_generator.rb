require 'sugar-high/file'
require 'sugar-high/module'
require 'cream'
require 'rails3_artifactor'
require 'logging_assist'
require 'active_support'

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
      class_option :migrations,     :type => :boolean,  :default => false,            :desc => "Autorun database migrations?", :aliases => '-m'

      def main_flow 
        return nil if !validate_orm            
        cream_initializer
        # cream_gems if gems?
        run_generators
        run_migrations if run_migrations?      
      end

      # -----------------      
      protected

      include Rails3::Assist::BasicLogger
      extend Rails3::Assist::UseMacro

      use_helpers :app, :special, :file

      def validate_orm
         if !valid_orms.include?(orm)
           say "ORM #{orm} is not currently supported. Please use one of: #{valid_orms}", :red
           false
         end
         true
      end

      def run_migrations?
        options[:migrations]
      end

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

      def run_migrations
        return if orm != 'active_record'
        execute "rake db:migrate"
      end

      def run_app
        rgen "cream:app --orm #{orm}"
      end

      def run_devise
        # rgen "devise:config --orm #{orm} --no-gems"
        rgen "devise:config --orm #{orm} #{admin_user_option}"
        rgen "devise:users --orm #{orm} #{admin_user_option} --no-gems"
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
        @orm ||= get_orm options[:orm].underscore.to_sym
      end

      def valid_orms
        active_record + data_mapper + mongo_mapper + [:couch_db, :mongoid]
      end

      def active_record
        [:ar, :active_record]
      end

      def mongo_mapper
        [:mm, :mongo_mapper]
      end

      def data_mapper
        [:dm, :data_mapper]
      end

      def get_orm orm_name
        return :active_record if active_record.include? orm_name
        return :mongo_mapper if mongo_mapper.include? orm_name
        return :data_mapper if data_mapper.include? orm_name
        return :couch_db if orm_name == :couch_db
        return :mongoid if orm_name == :mongoid
      end

      def default_roles?
        options[:default_roles]
      end

      def roles_list
        roles.join(' ')
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


      # def cream_gems
      #   if !has_gem? :cream
      #     gem 'cream' 
      #   end
      # end      

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
    end
  end
end

