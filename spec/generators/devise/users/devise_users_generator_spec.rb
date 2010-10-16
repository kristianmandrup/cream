require 'generator_spec_helper'
require_generator :devise => :users

LOGFILE = 'devise-users.log'

describe 'Generator' do
  use_orm :active_record
  use_helpers :controller, :special, :app, :file

  before do              
    setup_generator :devise_users_generator do
      tests Devise::Generators::UsersGenerator
    end    
  end

  describe "Configure Rails 3 app with Devise Users" do

    before do
      orm = :active_record

      Dir.chdir Rails.root do        
        @generator = with_generator do |g|
          arguments = "--admin-user --orm #{orm} --logfile #{LOGFILE}".args 
          g.run_generator arguments
        end
      end
    end

    describe 'result of Devise users generator' do
      it "should create Devise user model User" do
        Rails.root.should have_model :user do |user_model|
          user_model.should match /:database_authenticatable/
        end
      end

      it "should create Devise user model Admin" do
        Rails.root.should have_model_file :admin do |admin_model|  
          admin_model.should inherit_from :user
          admin_model.should have_default_devise_options
        end                                
      end
    end
  end
end
