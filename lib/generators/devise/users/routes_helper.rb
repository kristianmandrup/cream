module DeviseUserGenerator
  module RoutesHelper
    def model_routes
      arg = "#{user_class.pluralize.underscore}"
      arg << ", :admins" if admin_user?
      arg
    end

    def routes_configure!
      routes_content = routes_for_roles
      puts "Insert into routes: #{routes_content}"
      insert_into_routes do
        routes_content
      end
    end

    def routes_for_roles    
      say customize_note, :green
    
      routes_customize_comment << roles_routes
    end

    def roles_except *names
      roles.reject {|r| names.include? r.to_sym }
    end

    def roles_routes 
      roles_to_route = roles_except(:guest).delete_if do |role|        
        is_there = !(read_routes_file =~ /devise_for :#{role.pluralize}, :class_name =>/).nil?
        logger.debug "not doing devise routing for #{role.pluralize} as it is already there" if is_there
        is_there
      end

      roles_to_route.each do |role|
        if read_routes_file =~ /devise_for :#{role.pluralize}/          
          logger.debug "removing old devise routing for: #{role}"
          File.remove_content_from routes_file, :where => /devise_for :#{role.pluralize}/
        end
      end

      logger.debug "performing devise role routing for: #{roles_to_route}"
      roles_to_route.map do |role|      
          %Q{
  devise_for :#{role.pluralize}, :class_name => '#{role.classify}', :controllers => {:registrations => 'devise/registrations', :sessions => 'main'} do
    match "/#{role.pluralize}/sign_in" => "devise/signin#new", :as => :#{role}_signin
    match "/#{role.pluralize}/sign_up" => "devise/registrations#new", :as => :#{role}_signup
  end
  }
      end.join("\n")
    end
    

    def routes_customize_comment
      return "" if read_routes_file =~ /customize controller action/
      %q{
# customize controller action if needed to render individual registration form for each role    
# Example:
# match "/editors/sign_up" => "user_registrations#new_editor", :as => :editor_signup

#  'user_registrations_controller.rb' with the action #new_editor
# def new_editor
#   build_resource({})
# end
# 
# and the registration form in 'views/user_registrations/new_editor.html.erb'
#
}
    end
  end
end