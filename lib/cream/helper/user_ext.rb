module Cream::Helper
  module UserExt 
    def guest_options
     session[:guest_options] ||= {}
    end

    def user_signed_in?
      the_current_user && !is_guest?
    end

    def user_session
      user_signed_in? ? super : session
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

    def set_language language_code
     current_user.language_code = language_code if the_current_user && the_current_user.respond_to? # :language_code # for non-guest user
     guest_options[:language_code] = language_code # for guest user
    end
  end
end