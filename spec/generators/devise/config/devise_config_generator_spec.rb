require 'generator_spec_helper'
require_generator :devise => :config

LOGFILE = 'devise-config.log'

describe 'Generator' do
  use_helpers :controller, :special, :app, :file

  before do              
    setup_generator :devise_config_generator do
      tests Devise::Generators::ConfigGenerator
    end    
  end

  describe "Configure Rails 3 app for use with Devise" do

    before do
      orm = :mongoid
      
      Dir.chdir Rails.root do        
        @generator = with_generator do |g|
          arguments = "--orm #{orm} --logfile #{LOGFILE}".args 
          g.run_generator arguments
        end
      end
    end

    describe 'result of Devise config generator' do
      it "should add devise gems" do
        Rails.root.should have_gem 'devise'
      end

      it "should add Devise before_filter to ApplicationController" do
        Rails.root.should have_controller :application do |app_controller|  
          app_controller.should match /before_filter :authenticate_user!/
        end
      end

      it "should add orm setting to devise initializer" do
        File.read(initializer_file(:devise)).should match /devise\/orm\/mongoid/
      end

      it "should add devise mailer setting to Applicaiton config" do
        File.read(application_file).should match /action_mailer.default_url_options/
      end
    end
  end
end
