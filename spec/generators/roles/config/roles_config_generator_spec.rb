require 'generator_spec_helper'
require_generator :roles => :config

LOGFILE = 'roles-config.log'

describe 'Generator' do
  use_orm :mongoid
  use_helpers :controller, :special, :file

  before :each do              
    setup_generator :roles_config_generator do
      tests Roles::Generators::ConfigGenerator
    end    
  end

  describe "Configure Rails 3 app for use with Roles" do
    before do    
      puts "Creating User model"
      
      create_model :user do
        '# user model'
      end

      create_initializer :cream do
        %q{
          Cream.setup do
            roles = :guest, :admin
          end
        }
      end            
      
      puts "Running generator"
      Dir.chdir Rails.root do        
        @generator = with_generator do |g|
          arguments = "--roles guest admin --orm mongoid --strategy admin_flag --logfile #{LOGFILE}".args 
          puts "arguments: #{arguments}"
          g.run_generator arguments
        end
      end
    end
  
    describe 'result of roles generator' do
      it "should have :roles_mongoid gem" do
        Rails.root.should have_gem 'roles_mongoid'
      end

      it "should set valid roles for the User model" do    
        Rails.root.should have_model :user do |user_model|
          user_model.should match /valid_roles_are Cream.roles/
        end
      end
    
      # it "should use the admin_flag roles strategy" do    
      #   Rails.root.should have_model :user do |user_model|
      #     user_model.should match /use_roles_strategy :admin_flag/
      #   end
      # end
    end
  end
end
