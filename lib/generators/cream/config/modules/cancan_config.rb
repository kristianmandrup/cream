module Cream::Generators 
  module Config
    module CanCan  
      def cancan_configure
        cancan_gems 
        cancan_exception_handling
      end
      
      def cancan_gems
        gem 'cancan'  
        gem 'cancan-rest-links'
      end

      # CanCan access denied exception handling
      def cancan_exception_handling
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
