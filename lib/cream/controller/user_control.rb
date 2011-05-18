module Cream
  module UserControl

    # as_role current_user_roles do |role| 
    #   role.update_attributes_of(Project).with params[:project] 
    #   role.create(Project).with params[:project] 
    # end
    def as_role role, &block
      yield RoleModelManager.new role
    end
    
    def as_roles *roles, &block
      yield RoleModelManager.new roles.flatten
    end

    class RoleModelManager
      attr_accessor :roles
      
      def initialize *roles
        @roles = roles.flatten
      end

      def update_attributes_of model_clazz
        AttributesUpdater.new model_clazz
      end

      def create model_clazz
        ModelCreator.new model_clazz
      end      
      
      class AttributesUpdater
        attr_accessor :clazz

        def initialize clazz
          @clazz = clazz
        end
        
        def with attributes = {}
          clazz.constantize.update_attributes(attributes.merge(:as => roles))
        end
      end
      
      class ModelCreator
        attr_accessor :clazz

        def initialize clazz
          @clazz = clazz
        end
        
        def with attributes = {}
          clazz.constantize.create(attributes.merge(:as => roles))
        end
      end      
    end

    def current_roles
      the_current_user.roles_list
    end

    def the_current_user
      if !session[:user_id]
        Guest.create(guest_options)
      end
      if session[:user_id]  
        begin
          clazz = session[:user_class_name].constantize
          clazz.find session[:user_id] 
        rescue Exception => e
          puts "Error with current_user: user_class_name = '#{session[:user_class_name]}' error: #{e}"
        end
      end
    end
    
    def current_user
      the_current_user
    end

    def role_subject
      the_current_user
    end      

    def set_language language_code
     current_user.language_code = language_code if the_current_user && the_current_user.respond_to? :language_code # for non-guest user
     guest_options[:language_code] = language_code # for guest user
    end    

    def guest_options
     session[:guest_options] ||= {}
    end

    def user_signed_in?
      the_current_user && !is_guest?
    end

    def is_guest?
      role_subject.has_only_role?(:guest)      
    end

    def user_session
      user_signed_in? ? super : session
    end
    
    # Sign in an user that already was authenticated. This helper is useful for logging
    # users in after sign up.
    #
    # Examples:
    #
    #   sign_in :user, @user                      # sign_in(scope, resource)
    #   sign_in @user                             # sign_in(resource)
    #   sign_in @user, :event => :authentication  # sign_in(resource, options)
    #
    def sign_in(resource_or_scope, *args)
      options  = args.extract_options!
      scope    = Devise::Mapping.find_scope!(resource_or_scope)
      resource = args.last || resource_or_scope
      expire_session_data_after_sign_in!
      warden.set_user(resource, options.merge!(:scope => scope))

      # set user id
      post_signin resource, options
    end

    def post_signin resource, options = {}
      session[:user_id] = resource.id
      session[:user_class_name] = resource.class.name
    end

    # Sign out a given user or scope. This helper is useful for signing out an user
    # after deleting accounts.
    #
    # Examples:
    #
    #   sign_out :user     # sign_out(scope)
    #   sign_out @user     # sign_out(resource)
    #
    def sign_out(resource_or_scope)
      scope = Devise::Mapping.find_scope!(resource_or_scope)
      warden.user(scope) # Without loading user here, before_logout hook is not called
      warden.raw_session.inspect # Without this inspect here. The session does not clear.
      warden.logout(scope)
      # user id   
      post_signout scope            
    end        
    
    def post_signout
      session[:user_id] = nil
    end
  end
end