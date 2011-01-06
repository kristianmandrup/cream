class ApplicationController < ActionController::Base
  def current_user
    cu = super           
    if defined? Cream::Role
      # Try to get instance of any of the available roles as the current user
      Cream::Role.available.each do |role|
        method = :"current_#{role}"
        cu ||= send method if respond_to?(method)
      end
    end    
    # if all else fails, the user is likely not signed in so create a Guest user for now    
    cu ||= Guest.create if defined?(Guest)
  end

  def user_signed_in?
    current_user && !current_user.has_role? :guest
  end

  def user_session
    user_signed_in? ? super : session
  end    
end