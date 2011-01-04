module DeviseUserGenerator
  module RoutesHelper
    def model_routes
      arg = "#{user_class.pluralize.underscore}"
      arg << ", :admins" if admin_user?
      arg
    end

    def routes_configure!
      insert_into_routes do
        routes_for_roles
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
      roles_except(:guest).map do |role|
        next if read_routes_file =~ /devise_for :#{role.pluralize}/
        %Q{
  devise_for :#{role.pluralize}, :class_name => '#{role.classify}'
  as :#{role} do
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