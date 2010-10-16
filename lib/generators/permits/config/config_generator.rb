require 'sugar-high/file'
require 'sugar-high/module'
require 'cream'
require 'rails3_artifactor'
require 'logging_assist'

module Permits
  module Generators 
    class ConfigGenerator < Rails::Generators::Base        
      desc "Configure Permits"

      # ORM to use
      class_option :orm,                :type => :string,   :default => 'active_record',  :desc => "ORM to use"
      class_option :logfile,            :type => :string,   :default => nil,              :desc => "Logfile location" 

      def configure_permits
      	logger.add_logfile :logfile => logfile if logfile
        logger.debug "Configure Permits"

		    permits_gems
		    permits_initializer

        # Run permits generator to generate permit for each role
        rgen "permits --roles #{roles}"
      end           

      protected        
      
      include Rails3::Assist::BasicLogger
      extend Rails3::Assist::UseMacro
      
      use_helpers :application

      def permits_gems
        gem 'cancan-permits'        
      end 

      def permits_initializer
        create_initializer_file :permits do 
          %Q{
Permits::Application.orm = #{options[:orm]}
}
      end		
      end 
    end
  end
end