require 'generator_spec_helper'
require_generator :permits => :config

LOGFILE = 'permits-config.log'

describe 'Generator' do
  use_helpers :controller, :special, :file

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
          arguments = "--orm mongoid --logfile #{LOGFILE}".args
          g.run_generator arguments
        end
      end
    end
    
    describe 'result of permits generator' do

      it "should add the gem :cancan-permits" do
        # TODO
        Rails.root.should have_gem 'cancan-permits'
      end

      it "should generate a permits initializer file with orm set to mongoid" do      
        File.read(initializer_file(:permits)).should match /Permits::Application.orm = mongoid/
      end      
    end
  end
end
