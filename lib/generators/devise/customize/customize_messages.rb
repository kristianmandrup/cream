module Devise
  module CustomizeMessage    
    class << self
      def say msg, option
        puts msg
      end
      
      def retrieve_password        
          say %q{Currently Cream only supports a username/password retrieval strategy for :active_record and :mongoid
Please help add a strategy for your ORM of choice by adding a FindRecord.#[orm] method to the Cream 'app_generator.rb' file. Thanks!
See: https://github.com/plataformatec/devise/wiki/How-To:-Allow-users-to-sign_in-using-their-username-or-email-address for how to do it!}, :yellow
      end
      
      def find_record  
            say %Q{Currently Cream only supports generic login strategy for :active_record and :mongoid.
  Please help add a strategy for your ORM of choice by adding a FindRecord#[name of your orm] method to the Cream 'app_generator.rb' file.

  How: Add a self#[orm]_find_record method in your User class, make it work, then submit it as a patch to Cream. It should be very simple :)

  The example for mongoid:
    ...
    module FindRecord
      def self.mongoid 
        #{FindRecord.mongoid}
      end
    end

  See: https://github.com/plataformatec/devise/wiki/How-To:-Allow-users-to-sign_in-using-their-username-or-email-address for how to do it!}, :yellow  
      end
      
      def locales_update
        say %q{
Modify config/locales/en.yml to contain something like:

activemodel:
  attributes:
    user:
      login: "Username or email"
  }, :green
      end
    end
  end
end