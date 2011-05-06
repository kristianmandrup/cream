require 'sugar-high/file'
require 'sugar-high/module'
require 'cream'
require 'rails_artifactor'
require 'generators/cream/helpers/all'

module Cream
  module Generators 
    class AppGenerator < ::Rails::Generators::Base
      desc "Configure Cream App"

      # ORM to use
      class_option :orm,        :type => :string,   :default => 'active_record',   :desc => "ORM to use"
      class_option :logfile,    :type => :string,   :default => nil,               :desc => "Logfile location" 
      class_option :logging,    :type => :boolean,  :default => false,             :desc => "Logging on?" 
      class_option :guest_user, :type => :boolean,  :default => true,              :desc => "Create guest user" 
      
      def configure_application
      	logit!

        app_orm unless active_record?

        set_orm        

        app_routes
        app_layout
                
        create_guest_user if guest_user?
      end

      protected

      include Cream::GeneratorHelper
      extend  RailsAssist::UseMacro
      use_helpers :app, :special, :file, :view, :model

      def app_orm        
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
          rgen "controller Welcome index"
          File.insert_into routes_file, :after => 'do', :content => 'root :to => "welcome#index"'
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
        debug! "insert_flash_displayer: #{name}"
        insert_into_view :layouts => :application, :after => '<body>' do
          %Q{<p class="#{name}"><%= #{name} %></p>}
        end
      end

      def create_guest_user
        remove_model :guest if has_model?(:guest)
        create_model :guest do
          %Q{ 
  # modify this as needed (for any forms using current_user)
  # attr_accessor :login, :password 
  # attr_accessor :username, :email
  # attr_accessor :country, :country_code, :language, :language_code, :city
            
  def self.create options = {}    
    Guest.new options.merge(session[:guest_options] || {})
  end

  def save
    false
  end 
  
  def save!
    false
  end

  def is? role
    role == :guest
  end

  def has_role? role
    is? role
  end

  def has_roles? *roles
    false
  end  

  def has_any_role? *roles
    roles.flat_uniq.to_symbols.include?(:guest)
  end  
}
        end
        say "A Guest user model has been created. Users that have not signed in will get an instance of this class as the current_user."
      end
    end
  end
end