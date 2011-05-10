module Cream
  module UserControl

    def current_user   
      if !session[:user_id]
        @guest ||= Guest.create(guest_options) 
        return @guest
      end
      if session[:user_id]  
        begin
          clazz = session[:user_class_name].constantize
          @current_user ||= clazz.find session[:user_id] 
          return @current_user
        rescue Exception => e
          puts "Error with current_user: user_class_name = '#{session[:user_class_name]}' error: #{e}"
        end
      end
    end

    def role_subject
      current_user
    end      

    def set_language language_code
     current_user.language_code = language_code if current_user && current_user.respond_to? :language_code # for non-guest user
     guest_options[:language_code] = language_code # for guest user
    end    

    def guest_options
     session[:guest_options] ||= {}
    end

    def user_signed_in?
      current_user && !is_guest?
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
      @current_user = nil      
    end
  end
end