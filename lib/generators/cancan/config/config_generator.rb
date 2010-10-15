require 'sugar-high/file'
require 'sugar-high/modules'
require 'cream'
require 'rails3_artifactor'
require 'logging_assist'

module CanCan
  module Generators 
    class ConfigGenerator < Rails::Generators::Base
      extend Rails3::Assist::UseMacro
        
      desc "Configure CanCan"

      class_option :logfile, :type => :string,   :default => nil, :desc => "Logfile location" 

      def cancan_configure
      	logger.add_logfile :logfile => logfile if logfile?        
        cancan_gems 
        cancan_exception_handling
      end

  	  protected

      def logfile?
        options[:logfile]
      end

      def cancan_gems
        gem 'cancan'  
        gem 'cancan-rest-links'
      end

      # CanCan access denied exception handling
      def cancan_exception_handling 
        return if File.read(controller_file :application) =~ /rescue_from CanCan::AccessDenied/

        insert_into_controller :application, :after => "ActionController::Base\n" do
          %{
  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = exception.message
    redirect_to root_url
  end
  }
        end
    end
  end
end