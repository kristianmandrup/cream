module Cream::Generators 
  module Config
    module Roles
      def configure_roles_gems
        gem "roles_#{orm}"
      end

      def configure_roles
        command = "rails g #{orm}:roles --strategy #{strategy} --roles #{roles} #{default_roles}"
        logger.debug command
        run command
      end      
    end
  end
end
