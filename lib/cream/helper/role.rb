module Cream::Helper
  module Role

    # for_any_user :signed_in
    # for_any_user :not_logged_in    
    # for_any_user :not_logged_in => true
    
    def for_any_user options = nil, &block
      yield if Labels.state_check Labels.extract(options), current_user
    end

    # not_for_any_user :signed_in
    # not_for_any_user :logged_out
    # not_for_any_user :logged_in => true

    def not_for_any_user options = nil, &block
      return if Labels.state_check Labels.extract(options), current_user
      yield 
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

    private

    module Labels
      class << self
        def extract options
          case options
          when Symbol
            return :logged_in if logged_in_labels.include?(options)
            return :logged_out if logged_out_labels.include?(options)
          when Hash
            return :logged_in if logged_in_labels.any? {|lab| options[lab] }
            return :logged_out if logged_out_labels.any? {|lab| options[lab] }    
          end    
          raise ArgumentException, "Unknown option #{options}"
        end

        def state_check state, current_user
          logged_in_check(state, current_user) || logged_out_check(state, current_user)
        end

        def logged_in_check state, current_user
          state == :logged_in && current_user && current_user.is?(:guest)
        end

        def logged_out_check state, current_user
          state == :logged_out && (!current_user || current_user && !current_user.is?(:guest))
        end

        def logged_in_labels
          [:logged_in, :signed_in, :not_logged_out, :not_signed_out]
        end

        def logged_out_labels
          [:logged_out, :signed_out, :not_logged_in, :not_signed_in]
        end  
      end
    end
  end    
end
