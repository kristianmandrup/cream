module DeviseUserGenerator
  module Helper
    def devise_strategies
      {
        :default  => [:database_authenticatable, :confirmable, :recoverable, :rememberable, :trackable, :validatable],
        :admin    => [:database_authenticatable, :confirmable, :recoverable, :rememberable, :trackable, :validatable]
      }
    end

    def inherit_model hash                         
      File.replace_content_from model_file_name(subclass(hash).as_filename), :where => /class #{admin_class_name}/, :with => "class #{admin_class_name} < #{superclass hash}"
    end

    def superclass hash
      hash.values.first
    end

    def subclass hash
      hash.keys.first.to_s.camelize         
    end

    def remove_inheritance user
      File.remove_content_from model_file_name(user.as_filename), :where => /<\s*ActiveRecord::Base/
    end  

    def has_admin_model?
      has_model? admin_class
    end

    def has_user_model?
      has_model? user_class        
    end

    def user_generator 
      active_record? ?  'devise' : "#{orm}:devise"
    end

    def has_devise_user? user
      return true if is_admin?(user) && !admin_class
      begin
        read_model(user) =~ /devise/
      rescue Exception => e
        logger.info "Exception for #has_devise_user? #{user}: #{e.message}"
        false
      end
    end

    def devise_users?
      has_devise_user?(user_class) && has_devise_user?(admin_class)
    end

    def is_admin? name
      name.to_s.underscore == admin_class
    end

    def admin_class_name
      admin_class.to_s.classify
    end
                
    def create_user_model name
      rgen "#{user_generator} #{name}"
    end  
  end
end