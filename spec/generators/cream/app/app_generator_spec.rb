require 'generator_spec_helper'
require_generator :cream => :app

LOGFILE = 'cream-app-config.log'

describe 'Generator' do
  use_helpers :controller, :special, :file, :view

  before :each do              
    setup_generator :cream_app_generator do
      tests Cream::Generators::AppGenerator
    end    
  end

  describe "Configure Rails 3 app as a Cream app" do    
    before do    
      Dir.chdir Rails.root do        
        @generator = with_generator do |g|
          arguments = "--orm mongoid --logfile #{LOGFILE}".args
          g.run_generator arguments
        end
      end
    end

    describe 'result of app generator' do       
      it "should replace requirement statements in application file" do      
        ["action_controller/railtie", "action_mailer/railtie", "active_resource/railtie", "rails/test_unit/railtie"].each do |req|
          req = Regexp.escape(req)
          read_application_file.should match /#{req}/
        end
      end

      it "should add notice and alert flash displayers to application layout" do
        [:alert, :notice].each do |name|
          read_view(:layouts, :application).should match /<%= #{name} %>/
        end
      end

      it "should generate MainController" do
        controller_file?(:main).should be_true
      end
      
      it "should add root to routes file" do
        read_routes_file.should match /root\s+:to\s*=>/
      end
    end
  end
end


