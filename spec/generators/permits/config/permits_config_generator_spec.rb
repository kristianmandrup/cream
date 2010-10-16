require 'generator_spec_helper'
require_generator :permits => :config

LOGFILE = File.dirname(__FILE__) + '/permits-config.log'

describe 'Generator' do
  use_helpers :controller, :special

  before :each do              
    setup_generator :permits_config_generator do
      tests Permits::Generators::ConfigGenerator
    end    
  end

  describe "Configure Rails 3 app for use with CanCan Permits" do
    before do    
      puts "Running generator"
      Dir.chdir Rails.root do        
        @generator = with_generator do |g|
          arguments = "--logfile #{LOGFILE}".args 
          puts "arguments: #{arguments}"
          g.run_generator arguments
        end
      end
    end
  end # before

  it "should generate a Devise User with only a :guest role using :role_string strategy" do
    # TODO
    @generator.should add_to_gemfile 'cancan', 'cancan-rest-links'              

    @generator.should have_controller :application do |app_controller|  
      app_controller.should match /rescue_from CanCan::AccessDenied/
    end
  end
end
