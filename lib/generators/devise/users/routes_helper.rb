module DeviseUserGenerator
  module RoutesHelper
    def model_routes
      arg = "#{user_class.pluralize.underscore}"
      arg << ", :admins" if admin_user?
      arg
    end

    def routes_configure!
      routes_content = default_signin_routes << user_type_routes
      puts "Insert into routes: #{routes_content}"
      insert_into_routes do
        routes_content
      end
    end
    
    def user_types_to_route 
      @user_types_to_route ||= user_types_except(:guest).delete_if do |user_type|
        name_user_types = user_type.pluralize
        is_there = !(read_routes_file =~ /devise_for :#{name_user_types}, :class_name =>/).nil?
        logger.debug "not doing devise routing for #{name_user_types} as it is already there" if is_there
        is_there
      end
    end

    def default_signin_routes 
      name_default_users = user_class.underscore.gsub('/', '_').pluralize
      default_user_class = user_class.classify
      %Q{
  match '/sign_in' => 'main#index'
  match '/log_in'  => 'main#index'

  devise_scope do
    get '/sign_in'  => 'main#index', :as => :new_user_session    
  end
      
  devise_for :#{name_default_users}, :class_name => '#{default_user_class}', :controllers => {:sessions => 'main'} do
    get '/sign_in' => 'main#index', :as => :new_user_session
  end}
    end

    def user_type_routes 
      user_types_to_route.each do |user_type|
        name_user_types = user_type.pluralize
        if read_routes_file =~ /devise_for :#{name_user_types}/          
          logger.debug "removing old devise routing for: #{name_user_types}"
          File.remove_content_from routes_file, :where => /devise_for :#{name_user_types}/
        end
      end

      logger.debug "performing devise role routing for: #{user_types_to_route}"

      user_types_to_route.map do |user_type| 
        name_user_types = user_type.pluralize     
        name_user_type = user_type.underscore.gsub('/', '_')
          %Q{            
  devise_for :#{name_user_types}, :class_name => '#{user_type.classify}', :controllers => {:registrations => 'devise/registrations', :sessions => 'main'} do
    match "/#{name_user_types}/sign_in" => "devise/sessions#new", :as => :#{name_user_type}_signin
    match "/#{name_user_types}/sign_up" => "devise/registrations#new", :as => :#{name_user_type}_signup
  end
  }
      end.join("\n")
    end    
    
    protected
    
    def roles_except *names
      roles.reject {|r| names.include? r.to_sym }
    end

    def user_types_except *names
      user_types.reject {|r| user_types.include? r.to_sym }
    end    
  end
end