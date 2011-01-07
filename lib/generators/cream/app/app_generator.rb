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
      class_option :orm,        :type => :string,   :default => 'active_record',   :desc => "ORM to use"
      class_option :logfile,    :type => :string,   :default => nil,               :desc => "Logfile location" 
      class_option :guest_user, :type => :boolean,  :default => true,              :desc => "Create guest user" 
      class_option :user_name,  :type => :boolean,  :default => false,             :desc => "Add username to User"

      class_option :user_class,  :type => :string,   :default => 'User',      :desc => "User class name"
      class_option :login_type,  :type => :string,   :default => 'generic',   :desc => "How to login: 'email', 'username', 'generic' (i.e 'username' or 'email')"      
      
      def configure_application
      	logger.add_logfile :logfile => logfile if logfile

        app_orm unless active_record?

        set_orm        

        app_routes
        app_layout
        
        add_user_name_to_user if add_user_name?
        
        create_guest_user if guest_user?
      end

      protected

      include Rails3::Assist::BasicLogger
      extend Rails3::Assist::UseMacro
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
        logger.debug "insert_flash_displayer: #{name}"
        insert_into_view :layouts => :application, :after => '<body>' do
          %Q{<p class="#{name}"><%= #{name} %></p>}
        end
      end

      def add_username_to_user
        rgen "migration add_username_to_users username:string"
        run_migrations
        add_accessible_username
        modify_authentication_keys 
        if login_attribute == :login
          add_virtual_login_accessor 
          modify_retrieve_password_strategy
          locales_update_msg
        end
      end

      def modify_retrieve_password_strategy
        if ![:active_record, :mongoid].include? orm
          say %q{Currently Cream only supports a username/password retrieval strategy for :active_record and :mongoid
Please help add a strategy for your ORM of choice by adding a #[orm]_retrieve_password_code method to the Cream 'app_generator.rb' file. Thanks!
See: https://github.com/plataformatec/devise/wiki/How-To:-Allow-users-to-sign_in-using-their-username-or-email-address for how to do it!}, :yellow
          return
        end
        insert_reset_password_keys_stmt # in devise initializer
        insert_into_model user_class do
          active_record_retrieve_password_code
        end
        
      end

      def add_accessible_username
        insert_into_model user_class do
          'attr_accessible :username'
        end
      end

      def add_virtual_login_accessor
        insert_into_model user_class do
          'attr_accessor :login'
        end
      end      

      def user_class
        options[:user_class] || 'User'
      end

      def login_attribute
        att = options[:login_attribute] || 'generic'
        return 'login' if att.to_sym == :generic
        return att if [:username, :email].include? att.to_sym
        raise ArgumentError, "Unknown login attribute strategy #{att}"
      end

      def insert_reset_password_keys_stmt
        File.insert_into initializer_file(:devise), 'config.reset_password_keys = [ :login ]', :after => 'Rails::Application'
      end

      def modify_authentication_keys
        replace_initializer_content :devise,  :where => authentication_keys_stmt, :with => authentication_keys_replacement(login_attribute)
      end

      def override_active_record_user_auth
        if ![:active_record, :mongoid].include? orm
          say %q{Currently Cream only supports generic login strategy for :active_record and :mongoid.
Please help add a strategy for your ORM of choice by adding a #[orm]_find_record method to the Cream 'app_generator.rb' file. Thanks!
Simply add a self#[orm]_find_record method in your User class, make it work, then submit it as a patch to Cream. It should be very simple
The example for mongoid:

  def self.find_record(login) 
    where(:username => login).or(:email => login).first
  end
  
See: https://github.com/plataformatec/devise/wiki/How-To:-Allow-users-to-sign_in-using-their-username-or-email-address for how to do it!}, :yellow
          return
        end
        insert_into_model user_class do
          send :"#{orm}_user_auth_code"
        end
      end

      def active_record_user_auth_code
        %q{
  # protected

  def self.find_for_database_authentication(conditions)
    login = conditions.delete(:login)
    where(conditions).where(["username = :value OR email = :value", { :value => login }]).first
  end
}
      end

      def mongoid_user_auth_code
        %q{
  protected

  def self.find_for_database_authentication(conditions)
    login = conditions.delete(:login)
    self.any_of({ :username => value }, { :email => login }).first
  end
}
      end

      # should not be ORM dependent
      def reset_password_instructions_code
        %q{
  # protected

   # Attempt to find a user by it's email. If a record is found, send new
   # password instructions to it. If not user is found, returns a new user
   # with an email not found error.
   def self.send_reset_password_instructions(attributes={})
     recoverable = find_recoverable_or_initialize_with_errors(reset_password_keys, attributes, :not_found)
     recoverable.send_reset_password_instructions if recoverable.persisted?
     recoverable
   end 
}
      end

      def handle_errors_code
        %q{
    unless record
      record = new

      required_attributes.each do |key|
        value = attributes[key]
        record.send("#{key}=", value)
        record.errors.add(key, value.present? ? error : :blank)
      end  
    end  
    record
}
      end

      def retrieve_password_code
        reset_password_instructions_code << find_recoverable_code
      end

      def find_recoverable_code
        %Q{
   # protected

   def self.find_recoverable_or_initialize_with_errors(required_attributes, attributes, error=:invalid)
     case_insensitive_keys.each { |k| attributes[k].try(:downcase!) }

     attributes = attributes.slice(*required_attributes)
     attributes.delete_if { |key, value| value.blank? }

     if attributes.size == required_attributes.size
       if attributes.has_key?(:login)
          login = attributes.delete(:login)
          record = find_record(login)
       else  
         record = where(attributes).first
       end  
     end  
     #{handle_errors_code}
   end
   
   def self.find_record login
     #{send :"#{orm}_find_record"}
   end
}
      end

      def active_record_find_record
        %q{where(attributes).where(["username = :value OR email = :value", { :value => login }]).first}
      end

      def mongoid_find_record(login)
        %q{where("function() {return this.username == '#{login}' || this.email == '#{login}'}").first}
      end  

      def mongo_mapper_find_record(login)
        %q{where("function() {return this.username == '#{login}' || this.email == '#{login}'}").first}
      end  

      def locales_update_msg
        say %q{
Modify config/locales/en.yml to contain something like:

activemodel:
  attributes:
    user:
      login: "Username or email"
}, :green
      end

      def authentication_keys_replacement name
        "config.authentication_keys = [ :#{name} ]"
      end
      
      def authentication_keys_stmt
        /# config.authentication_keys = [\s*:email\s*]/
      end
      
      def create_guest_user
        remove_model :guest if has_model?(:guest)
        create_model :guest do
          %Q{
  def self.create
    Guest.new
  end

  def has_role? role
    role == :guest
  end

  def has_roles? *roles
    false
  end  

  def has_any_role? *roles
    roles.flat_uniq..to_symbols.include? :guest
  end  
}
        end
        say "A Guest user model has been created. Users that have not signed in will get an instance of this class as the current_user."
      end

      protected
      
      def guest_user?
        options[:gust_user]
      end
      
      def add_user_name?
        options[:user_name] && active_record?
      end      
    end
  end
end