module Cream::Generators 
  module Config
    module Permits      
      def permits_gems
        gem 'cancan-permits'        
      end 
      
      def configure_permits
        logger.debug "Configure Permits"
        # Run permits generator to generate permit for each role
        execute "rails g permits --roles #{roles}"
      end           
    end
  end
end
