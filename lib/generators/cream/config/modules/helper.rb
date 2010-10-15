module Cream::Generators 
  module Config
    module Helpers

      ORM_MAP = {
        :data_mapper  => 'dm-devise',
        :mongo_mapper => 'mm-devise',
        :mongoid      => 'rails3-mongoid-devise'                
      }

      # rails generate ...
      def rgen command
        execute "rails g #{command}"
      end        

      def execute command
        logger.debug command
        run command
      end        

      def strategy
        options[:strategy]      
      end

      def logfile
        options[:logfile]      
      end

      def users 
        extra_users = admin_user? ? :admin : nil
        @users ||= ([:user] + extra_users).compact
      end

      def roles
        @roles ||= options[:roles].join(' ')
      end

      def roles_generator
        "#{orm}:roles"
      end

      def user_generator 
        active_record? ? "#{orm}:devise" : 'devise'
      end

      def active_record? 
        orm == 'active_record'
      end

      def orm
        options[:orm]
      end

      def default_roles?
        options[:default_roles]
      end

      def roles_config?
        options[:roles_config]
      end

      def permission_config?
        options[:permission_config]
      end

      def admin_user?
        options[:admin_user]
      end

      def here
        File.dirname(__FILE__)
      end

      def root_dir
        File.dirname(__FILE__).up(4)
      end
    end
  end
end