require 'sugar-high/file'
require 'sugar-high/module'
require 'cream'
require 'rails_artifactor'
require 'generators/cream/helpers/all'

module Cancan
  module Generators 
    class ConfigGenerator < Rails::Generators::Base        
      desc "Configure CanCan"

      class_option :logfile, :type => :string,   :default => nil,   :desc => "Logfile location"
      class_option :gems,    :type => :boolean,  :default => false, :desc => "Add gems to gemfile?"       

      def cancan_configure
      	logit!
        cancan_gems if gems?
        cancan_exception_handling
      end

  	  protected

      extend  RailsAssist::UseMacro 
      include Cream::GeneratorHelper      

      use_helpers :controller, :app      

      def gems?
        options[:gems]        
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
          debug! "CanCan rescue statement already exists"
          return
        end
        
        debug! "Insert cancan rescue statement into application controller"
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