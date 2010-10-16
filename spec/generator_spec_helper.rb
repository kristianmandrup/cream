require 'rspec/core'    
require 'generator-spec'
require 'devise-spec'
require 'roles-spec'
require 'cream'

RSpec::Generator.configure do |config|
  config.debug = false
  config.remove_temp_dir = false # true
  config.default_rails_root(__FILE__) 
  config.lib = File.dirname(__FILE__) + '/../lib'
  config.logger = :stdout    
end

RSpec.configure do |config|
  config.mock_with :mocha 
   
  config.before do
    # create_rails_app
  end
  
  # config.after do
  #   remove_rails_app
  # end  
end

