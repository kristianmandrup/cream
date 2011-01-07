require 'sugar-high/file'
require 'sugar-high/module'
require 'cream'
require 'rails3_artifactor'
require 'logging_assist'

require_all File.dirname(__FILE__) # + '/helpers'

module Devise
  module Generators 
    class CustomizeGenerator < ::Rails::Generators::Base
      desc "Customize Devise"

      # ORM to use
      class_option :orm,        :type => :string,   :default => 'active_record',   :desc => "ORM to use"
      class_option :logfile,    :type => :string,   :default => nil,               :desc => "Logfile location"

      class_option :user_class,  :type => :string,   :default => 'User',      :desc => "User class name"
      class_option :login_type,  :type => :string,   :default => 'generic',   :desc => "How to login: 'email', 'username', 'generic' (i.e 'username' or 'email')"
      
      def main_flow
      	logger.add_logfile :logfile => logfile if logfile

        Devise::Customizers::UserName.new(orm, user_class).add_to_user_class if add_user_name?    
      end

      protected

      include Cream::GeneratorHelper
      include Rails3::Assist::BasicLogger
            
      def user_class
        options[:user_class] || 'User'
      end

      def login_attribute
        att = options[:login_attribute] || 'generic'
        return 'login' if att.to_sym == :generic
        return att if [:username, :email].include? att.to_sym
        raise ArgumentError, "Unknown login attribute strategy #{att}"
      end
      
      def add_user_name?
        options[:user_name] && active_record?
      end
    end
  end
end
      