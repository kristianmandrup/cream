require 'sugar-high/file'
require 'sugar-high/module'
require 'cream'
require 'rails3_artifactor'
require 'logging_assist'

module Cream
  module Generators
  end
end

# require_all File.dirname(__FILE__) + '/modules'

module Cream::Generators 
  class ConfigGenerator < Rails::Generators::Base        
    desc "Configures Devise and Users" 

    source_root File.dirname(__FILE__)

    # Role Strategy
    class_option  :strategy,          :type => :string,   :default => 'role_string',    :desc => "Role strategy to use"

    # Create Admin user
    class_option :admin_user,         :type => :boolean,  :default => false,            :desc => "Create admin user"  

    # Roles
    class_option :default_roles,      :type => :boolean,  :default => true,             :desc => "Create default roles :admin and :guest"
    class_option :roles,              :type => :array,    :default => [],               :desc => "Roles to create"

    # Permits
    class_option :permits,            :type => :boolean,  :default => true,             :desc => "Configure permits or not"

    # ORM to use
    class_option :orm,                :type => :string,   :default => 'active_record',  :desc => "ORM to use"

    class_option :logfile,            :type => :string,   :default => nil,              :desc => "Logfile location"

    class_option :configure,          :type => :array,    :default => [],               :desc => "Which generators to run"

    def main_flow 
      cream_gems
      cream_initializer      
    end

    # -----------------      
    protected

    include Rails3::Assist::BasicLogger
    extend Rails3::Assist::UseMacro

    use_helpers :app, :special, :file

    def logfile
      options[:logfile]
    end


    def run_generators
      # after setting up all gems so other generators are available
      # run those generators to do the heavy lifting!
      run_app if configures.include? :app      
    end

    def run_app
      rgen "cream:app --orm #{orm}"
    end

    def orm
      options[:orm]
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
      return [:app, :permits, :roles, :devise] if options[:configure].empty? 
      options[:configure].map{|c| c.to_sym}
    end

    def make_generators_available
      gem 'cancan-permits'
    end

    ORM_MAP = {
      :data_mapper  => 'dm-devise',
      :mongo_mapper => 'mm-devise',
      :mongoid      => 'rails3-mongoid-devise'                
    }

    def cream_gems
      gem_name = ORM_MAP[orm.to_sym]
      gem gem_name if gem_name
      gem 'cream'
      # bundle_install
    end      

    def cream_initializer
      create_initializer_file :cream do         
%Q{Cream.setup do |config|
  config.roles = #{roles.inspect} 
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