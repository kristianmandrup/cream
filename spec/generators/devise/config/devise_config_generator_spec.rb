require 'spec_helper'

LOGFILE = File.dirname(__FILE__) + '/cancan-config.log'

describe 'Generator' do
  use_helpers :controller, :special

  before :each do              
    setup_generator :permits_config_generator do
      tests Permits::Generators::ConfigGenerator
    end    
  end

  describe "Configure Rails 3 app for use with Devise" do
    before do    
      puts "Running generator"
      
      orm = :active_record
      
      Dir.chdir Rails.root do        
        @generator = with_generator do |g|
          arguments = "--orm #{orm} --logfile #{LOGFILE}".args 
          puts "arguments: #{arguments}"
          g.run_generator arguments
        end
      end
    end
  end # before

  it "should configure app for Devise" do
    # TODO
    @generator.should add_to_gemfile 'devise'

    @generator.should have_controller :application do |app_controller|  
      app_controller.should match /before_filter :authenticate_user!/
    end
  end
end
