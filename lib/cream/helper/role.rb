module Cream::Helper
  module Role

    def for_any_user &block
      yield if current_user
    end
    
    # does the user have ANY of the given roles?
    # Uses generic roles API    
    def has_role? user_role
      current_user && current_user.has_role?(user_role)
    end

    # does the user have ALL of the given roles?
    # Uses generic roles API
    def has_roles? *roles
      current_user && current_user.has_roles?(roles.flat_uniq)
    end

    # returns true if the current user owns the object
    # tries default 'owner' relations if none given as an argument
    def owner? obj, relation=nil
      if relation     
        return true if user_relation?(obj, relation)
      end                                
      [:user, :owner, :author].each do |relation|        
        return true if user_relation?(obj, relation)
      end
      false
    end    

    # execute block if user DOES have any of the given roles
    def for_roles *user_roles, &block
      user_roles = user_roles.flatten
      yield if has_role?(user_roles) && block
    end 

    def for_any_role *user_roles, &block
      user_roles = user_roles.flatten
      yield if has_role?(user_roles) && block
    end 


    def for_role user_role, &block
      yield if has_role?(user_role) && block
    end 
    

    # execute block if user DOES NOT have any of the given roles
    def not_for_roles(*user_roles, &block)            
      user_roles = user_roles.flatten
      yield if !has_role?(user_roles) && block
    end        

    def not_for_role(user_role, &block)
      yield if !has_role?(user_role) && block
    end        

    protected
    
    def user_relation? obj, relation
      raise ArgumentError, "User method must be a Symbol or String" if !relation.kind_of_label?
      current_user && is_owner?(current_user, obj, relation)
    end
    
    def is_owner? user, obj, relation
      user == obj.send(relation) if obj.respond_to? relation      
    end
  end    
end
