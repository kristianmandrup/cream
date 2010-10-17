require 'generator_spec_helper'
require_generator :cream => :config

LOGFILE = 'cream-config.log'

describe 'Generator' do
  use_helpers :controller, :special, :file, :view

  before :each do              
    setup_generator :cream_app_generator do
      tests Cream::Generators::ConfigGenerator
    end    
  end

  before do    
    Dir.chdir Rails.root do        
      @generator = with_generator do |g|
        arguments = "--orm mongo_mapper --logfile #{LOGFILE}".args
        g.run_generator arguments
      end
    end
  end

  describe "Configure Rails 3 app as a Cream configured app" do    
    describe 'result of Cream config generator' do       
      it "should add cream gem" do
        Rails.root.should have_gem 'cream'
        Rails.root.should have_gem 'mm-devise'        
      end

      # it "should add mongoid devise gem" do
      #   Rails.root.should have_gem 'mm-devise'
      # end
    end
  end
end


