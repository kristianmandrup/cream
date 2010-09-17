module Cream::Generators 
  module Config
    module Cream
      def cream_gems
        gem_name = ORM_MAP[orm]      
        gem gem_name if gem_name        
        
        gem 'devise'
        gem 'cancan'          
        gem 'cream'
        run "bundle install"
      end      
      
      def configure_locale
        src = File.expand_path "config/locales/en.yml".path.up(2)
        # src = "config/locales/en.yml"
        logger.debug "configure_locale, copy from: #{src}"            
        copy_file src, "config/locales/cream.en.yml"
      end
    end
  end
end

