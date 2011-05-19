# To redefine current_user method:
# 
# create a file in /lib/user_ext.rb
# 
# module Cream::Helper
#   module UserExt 
#     def current_user
#       the_current_user
#     end
#   end
# end
# 
# then require this file in a rails initializer you create, fx called xtras.rb

# - initializers/xtras.rb
#
# require 'user_ext'

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

    # You can redefine this if needed, fx calling #devise_current_user
    def current_user
      the_current_user
    end

      # call devise method  
    def devise_current_user
    end
    
    # perhaps use trick to have pointer to devise #current_user method
  end
end