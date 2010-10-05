module Cream::Generators 
  module Config
    module Cream 
      def cream_configure
        cream_gems
        cream_initializer
        cream_locale
      end
      
      def cream_gems
        gem_name = ORM_MAP[orm]      
        gem gem_name if gem_name        
        
        gem 'cream'
        run "bundle install"
      end      

      def cream_initializer
        create_initializer_file :cream do 
          %Q{
Cream.setup do |config|
  config.roles = #{roles.inspect} 
end
}
      end
      
      def cream_locale
        src = File.expand_path "config/locales/en.yml".path.up(2)
        # src = "config/locales/en.yml"
        logger.debug "configure_locale, copy from: #{src}"            
        copy_file src, "config/locales/cream.en.yml"
      end
    end
  end
end

