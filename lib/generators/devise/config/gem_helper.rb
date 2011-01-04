module DeviseConfigGenerator
  module GemHelper
    def gems_mongo_db
      add_gem 'bson_ext', '>= 1.1.4'
    end

    def devise_mongoid_setup
      rgen 'mongoid:config'
      rgen "devise mongoid" 
    end

    def configure_gems_active_record
      say "Configuring for Active Record"
    end

    def configure_gems_data_mapper
      say "Configuring for Data Mapper"
      add_gem 'dm-devise'
    end        

    def configure_gems_mongo_mapper
      say "Configuring for Mongo Mapper"
      add_gem 'mm-devise'
      gems_mongo_db          
    end

    def configure_gems_mongoid
      say "Configuring for Mongoid"
      # say "Please configure Devise for Mongoid similar to Rails 3 example app: http://github.com/fortuity/rails3-mongoid-devise"
      add_gem 'mongoid', '>= 2.0.0.beta.20'
      gems_mongo_db
    end

    def configure_gems_couch_db
      say "Configuring for Couch DB"
      add_gem 'devise_couch'
      say "WARNING: Couch DB does not currently have a complete Roles implementation (admin_flag only). Please help implement the Roles strategy adapter.", :yellow
    end

    def add_gem_version name, version
      if !has_gem_version?(name, version)
        logger.debug "Adding gem: #{name}, #{version}"
        gem name, :version => version
      else
        logger.debug "gem: #{name}, #{version} already in Gemfile"
      end        
    end

    def add_gem name, version = nil
      if version
        add_gem_version name, version 
        return 
      end
  
      if !has_gem? name
        logger.debug "Adding gem: #{name}"
        gem name
      else
        logger.debug "gem: #{name} already in Gemfile"          
      end
    end
  end
end