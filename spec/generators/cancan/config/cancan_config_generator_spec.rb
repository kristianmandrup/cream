require 'generator_spec_helper'
require_generator :cancan => :config

LOGFILE = 'cancan_config.log'

describe 'Generator' do
  use_helpers :controller, :special, :app, :directory, :file

  before :each do              
    setup_generator 'config_generator' do
      tests Cancan::Generators::ConfigGenerator
    end    
  end

  describe "Configure Rails 3 app for use with CanCan" do
    before do
      Dir.chdir Rails.root do        
        @generator = with_generator do |g|
          arguments = "--logfile #{LOGFILE}".args 
          g.run_generator arguments
        end
      end
    end

    it "should add cancan gems" do
      Rails.root.should have_gems 'cancan', 'cancan-rest-links'
    end

    it "should add CanCan rescue clause to ApplicationController" do
      Rails.root.should have_controller :application do |app_controller|
        puts app_controller
        app_controller.should match /rescue_from CanCan::AccessDenied/
      end
    end
  end
end
