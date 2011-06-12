require 'sugar-high/file_mutate'
File.mutate_ext :all

require 'sugar-high/module'
require 'cream'
require 'rails_artifactor'
require 'generators/cream/helpers/all'

require_all File.dirname(__FILE__) # + '/helpers'

module Devise
  module Generators 
    class CustomizeGenerator < ::Rails::Generators::Base
      desc "Customize Devise"

      argument :user_class,  :type => :string,   :default => 'User',      :desc => "User class name"

      # ORM to use
      class_option :orm,        :type => :string,   :default => 'active_record',   :desc => "ORM to use"
      class_option :logging,    :type => :boolean,  :default => false,             :desc => "Logging on?" 
      class_option :logfile,    :type => :string,   :default => nil,               :desc => "Logfile location"

      class_option :user_name,   :type => :boolean,  :default => true,        :desc => "Add username as login option"
      class_option :login_type,  :type => :string,   :default => 'generic',   :desc => "How to login: 'email', 'username', 'generic' (i.e 'username' or 'email')"
      
      def main_flow
        logit!
      	debug! 'customizing devise...'

        Devise::Customizers::UserName.new(orm, user_class, login_attribute).add_to_user_class if add_user_name?    
      end

      protected

      include Cream::GeneratorHelper
            
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
      