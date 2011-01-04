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
      roles_routes = roles.each do |role|
        %Q{
devise_for :#{role.pluralize}, :class_name => '#{role.classify}'
as :#{role} do
  match "/#{role.pluralize}/sign_up" => "devise/registrations#new", :as => :#{role}_signup
end
}
      end
    
      say customize_note, :green
    
      routes_customize_comment + roles_routes
    end

    def routes_customize_comment
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