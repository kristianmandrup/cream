require 'sugar-high/file'
require 'sugar-high/module'
require 'cream'
require 'rails3_artifactor'
require 'logging_assist'

module Cream
  module Generators 
    class AppGenerator < ::Rails::Generators::Base
      desc "Configure Cream App"

      # ORM to use
      class_option :orm,     :type => :string,   :default => 'active_record',   :desc => "ORM to use"
      class_option :logfile, :type => :string,   :default => nil,               :desc => "Logfile location" 

      def configure_application
      	logger.add_logfile :logfile => logfile if logfile
        app_orm
        app_routes
        app_layout
      end

      protected

      include Rails3::Assist::BasicLogger
      extend Rails3::Assist::UseMacro
      use_helpers :app, :special, :file, :view

      def logfile
        options[:logfile]
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

      def app_orm
        return if orm == 'active_record'
        File.replace_content_from application_file,  :where => "require 'rails/all'" do 
        %q{
require "action_controller/railtie"
require "action_mailer/railtie"
require "active_resource/railtie"
require "rails/test_unit/railtie"
}
        end
      end
       
      def app_routes
        routes = read_routes_file
        # if no :welcome controller
        if !(routes =~ /root\s+:/)
          # create one with an 'index' view.
          File.insert_into routes_file, :after => 'do', :content => 'root :to => "welcome#index"'          
          rgen "controller Welcome index"
        end
      end
      
      # in 'app/views/layouts/application.html.erb'
      # insert special flash msg displayers after opening <body> element
      def app_layout
        layout_content = read_view :layouts => :application        
        [:alert, :notice].each{|name| insert_flash_displayer name, layout_content}
      end
      
      def insert_flash_displayer name, layout_content
        return if layout_content =~ /<%=\s+#{name}\s+%>/          
        logger.debug "insert_flash_displayer: #{name}"
        insert_into_view :layouts => :application, :after => '<body>' do
          %Q{<p class="#{name}"><%= #{name} %></p>}
        end
      end      
    end
  end
end