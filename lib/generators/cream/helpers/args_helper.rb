module Cream
  module GeneratorHelper
    module Args 
      def logfile
        options[:logfile]
      end

      def default_roles?
        options[:default_roles]
      end

      def roles         
        defaults = default_roles? ? ['guest', 'admin'] : [] 
        options[:roles] + defaults
      end
      
      def has_user_model?
        model_file?(user_class)
      end

      def set_orm
        self.class.use_orm :"#{orm}"
      end

      def admin_user_option
        admin_user? ? "--admin-user #{admin_user}" : ''
      end

      def roles_list
        roles.join(' ')
      end

      def gems?
        options[:gems]        
      end

      def document_store?
        [:mongoid, :mongo_mapper, :couch_db].include? orm
      end

      def active_record? 
        active_record.include? orm
      end

      def mongoid? 
        orm == :mongoid
      end
      
      def strategy
        options[:strategy]
      end        

      def admin_user?
        options[:admin_user]
      end
      
      def sym_roles
        roles.map(&:to_sym)
      end

      def user_class
        options[:user_class] || 'User'
      end

      def admin_class
        options[:admin_class] || 'Admin'
      end

      def role_class
        options[:role_class] || 'Role'
      end

      def user_role_class
        options[:user_role_class] || 'UserRole'
      end                        
    end
  end
end