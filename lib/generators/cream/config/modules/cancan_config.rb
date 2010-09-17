module Cream::Generators 
  module Config
    module CanCan
      def configure_devise_gems
        gem 'cancan'  
        gem 'cancan-rest-links'
      end

      # CanCan access denied exception handling
      def configure_exception_handling         
        insert_into_controller :application, :after => "ActionController::Base\n" do
          %{
  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = exception.message
    redirect_to root_url
  end
  }
        end
      end      
    end
  end
end
