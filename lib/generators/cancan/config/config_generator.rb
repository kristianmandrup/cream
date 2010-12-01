require 'sugar-high/file'
require 'sugar-high/module'
require 'cream'
require 'rails3_artifactor'
require 'logging_assist'

module Cancan
  module Generators 
    class ConfigGenerator < Rails::Generators::Base        
      desc "Configure CanCan"

      class_option :logfile, :type => :string,   :default => nil,   :desc => "Logfile location"
      class_option :gems,    :type => :boolean,  :default => false, :desc => "Add gems to gemfile?"       

      def cancan_configure
      	logger.add_logfile :logfile => logfile if logfile        
        cancan_gems if gems?
        cancan_exception_handling
      end

  	  protected

      include Rails3::Assist::BasicLogger
      extend Rails3::Assist::UseMacro

      use_helpers :controller, :app      

      def gems?
        options[:gems]        
      end

      def logfile
        options[:logfile]
      end

      def cancan_gems
        gem 'cancan'  
        gem 'cancan-rest-links'
        bundle_install #'cancan', 'cancan-permits'
      end

      def bundle_install #*gems
        run "bundle install" # #{gems.jon(' ')}"
      end

      # CanCan access denied exception handling
      def cancan_exception_handling
        if rescue_exists?
          logger.debug "CanCan rescue statement already exists"
          return
        end
        
        logger.debug "Insert cancan rescue statement into application controller"
        insert_into_controller :application, :after => "ActionController::Base\n" do
          %{
  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = exception.message
    redirect_to root_url
  end
  }
        end
      end
       
      def rescue_exists? 
        !(File.read(controller_file :application) =~ /rescue_from CanCan::AccessDenied/).nil?
      end
    end
  end
end