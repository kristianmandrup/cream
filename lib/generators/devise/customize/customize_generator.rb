require 'sugar-high/file'
require 'sugar-high/module'
require 'cream'
require 'rails3_artifactor'
require 'logging_assist'
require 'generators/cream/helpers/all'

require_all File.dirname(__FILE__) # + '/helpers'

module Devise
  module Generators 
    class CustomizeGenerator < ::Rails::Generators::Base
      desc "Customize Devise"

      argument :user_class,  :type => :string,   :default => 'User',      :desc => "User class name"

      # ORM to use
      class_option :orm,        :type => :string,   :default => 'active_record',   :desc => "ORM to use"
      class_option :logfile,    :type => :string,   :default => nil,               :desc => "Logfile location"

      class_option :user_name,   :type => :boolean,  :default => true,        :desc => "Add username as login option"
      class_option :login_type,  :type => :string,   :default => 'generic',   :desc => "How to login: 'email', 'username', 'generic' (i.e 'username' or 'email')"
      
      def main_flow
      	logger.add_logfile :logfile => logfile if logfile
      	logger.debug 'customizing devise...'

        Devise::Customizers::UserName.new(orm, user_class, login_attribute).add_to_user_class if add_user_name?    
      end

      protected

      include Cream::GeneratorHelper
      include Rails3::Assist::BasicLogger
            
      def login_attribute
        att = options[:login_attribute] || 'generic'
        return 'login' if att.to_sym == :generic
        return att if [:username, :email].include? att.to_sym
        raise ArgumentError, "Unknown login attribute strategy #{att}"
      end
      
      def add_user_name?
        options[:user_name] && is_default_devise_orm?
      end
    end
  end
end
      