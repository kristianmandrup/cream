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
  
  config.before do
    Dir.chdir Rails.root.path + '/../' do
      FileUtils.rm_rf "rails_app"
      %x[rails new rails_app --force]
    end
  end

  config.after do
    FileUtils.rm_rf Rails.root
  end  
end