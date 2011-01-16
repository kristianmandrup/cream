module Cream
  module UserControl
    def current_user
      return session[:the_user] if session[:the_user]
      if defined? Cream::Role
        # Try to get instance of any of the available roles as the current user
        Cream::UserTypes.available.each do |user_type|
          method = :"current_#{role}"         
          if respond_to?(method)
            session[:the_user] ||= send(method) 
            return session[:the_user] if session[:the_user]           
          end
        end
      end    
      session[:the_guest] ||= Guest.create if defined?(Guest)
    end

    def user_signed_in?
      current_user && !current_user.has_role?(:guest)
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
      session[:the_guest] = nil
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
      session[:the_user] = nil      
    end        
  end
end