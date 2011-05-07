require 'sugar-high/file'
require 'sugar-high/module'
require 'cream'
require 'rails_artifactor'
require 'generators/cream/helpers/all'

module Permits
  module Generators 
    class ConfigGenerator < Rails::Generators::Base        
      desc "Configure Permits"

      # ORM to use
      class_option :orm,            :type => :string,   :default => 'active_record',    :desc => "ORM to use"
      class_option :roles,          :type => :array,    :desc => "Roles for permits"
      class_option :default_roles,  :type => :boolean,  :default => true,  :desc => "Create default roles :admin and :guest"      

      class_option :logging,    :type => :boolean,  :default => false,             :desc => "Logging on?" 
      class_option :logfile,  :type => :string,   :default => nil,                :desc => "Logfile location" 
      class_option :gems,     :type => :boolean,  :default => false,              :desc => "Add gems to gemfile?"       

      def configure_permits
      	logit!
        debug! "Configure Permits"

		    permits_gems if gems?

        # Run permits generator to generate permit for each role
        rgen "cancan:permits #{roles_list} --orm #{orm}"
        # rgen "cancan:permits --roles #{roles_list} --orm #{orm}"
        rgen "cancan:licenses"
      end

      protected

      include Cream::GeneratorHelper
      
      def permits_gems
        gem 'cancan-permits'
        bundle_install # 'cancan-permits'
      end
    end
  end
end