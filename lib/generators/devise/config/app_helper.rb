module DeviseConfigGenerator
  module AppHelper    
    def protection_configure!
      debug! "Configuring: devise authentication filter"
      ## Add Devise protection to Application controller:
      insert_into_controller :application do
        "before_filter :authenticate_user!"
      end
    end

    # inside 'config/initializers/devise.rb' change to:
    # require 'devise/orm/mongo_mapper'
    def orm_configure!
      return if orm == :active_record
      debug! "Configuring orm: [#{orm}]"
      
      if !devise_initializer?        
        say "WARNING: initializer/devise.rb not found", :yellow
        return
      end
        
      if !has_statement?(orm_replacement)
        debug! "require 'devise/orm/#{orm}' already in devise.rb initializer"
        return
      end

      if !has_devise_orm_statement?
        say "WARNING: devise/orm statement not found in devise.rb initializer", :yellow
        return
      end
      
      replace_initializer_content :devise,  :where => orm_statement, :with => orm_replacement
    end
      
    def mailer_configure!
      debug! "Configuring: devise mailer"            
      insert_application_config "action_mailer.default_url_options = { :host => 'localhost:3000' }"
    end
    
    private
    
    def devise_initializer 
      initializer_file(:devise)
    end

    def devise_initializer? 
      initializer_file?(:devise)
    end        

    def devise_initializer_content 
      File.new(devise_initializer).read
    end
    
    def has_devise_orm_statement?
      devise_initializer_content =~ orm_statement
    end

    def has_statement? statement
      devise_initializer_content =~ /#{Regexp.escape(statement)}/
    end

    def has_devise_orm_replacement?
      has_statement? orm_replacement
    end

    def orm_statement   
      /devise\/orm\/\w+/
    end

    def orm_replacement 
      "devise/orm/#{orm}"
    end               
  end
end
