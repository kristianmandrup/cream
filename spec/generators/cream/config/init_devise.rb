require 'generator_spec_helper'
require_generator :cream => :config

LOGFILE = File.expand_path File.dirname(__FILE__) + '/../../config_generator-init.log'

describe 'Cream config generator: strategy "admin_flag", init Devise user model User' do
  use_helpers :model, :controller, :permit, :files, :file
  
  before :each do              
    setup_generator 'config_generator' do
      tests Cream::Generators::ConfigGenerator
    end    
    remove_all_permits
    remove_locale :cream
    
    File.remove_from controller_file(:application) do
          %{
  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = exception.message
    redirect_to root_url
  end
}
    end
  end

  after :each do
    remove_all_permits
  end

  describe "Configure Rails 3 app with Cream using init devise" do
    before do    
      puts "Running generator"
      Dir.chdir Rails.root do        
        @generator = with_generator do |g|
          arguments = "--strategy admin_flag --init-devise --logfile #{LOGFILE}".args 
          puts "arguments: #{arguments}"
          g.run_generator arguments
        end
      end
    end # before
      
    it "should generate a Devise User with only a :guest role using :role_string strategy" do
      @generator.should generate_model :user do |clazz|
        clazz.should have_default_devise_options

        # clazz.should use_roles :generic
        # clazz.should include_module 'Roles::Generic'
        # clazz.should have_call :roles,          :args => ':guest'
        # clazz.should have_call :role_strategy,  :args => ":role_string"
      end
    end # it  
  
    # it "should generate a Devise Admin user" do
    #   @generator.should generate_model :admin do |clazz|
    #     # clazz.should use_roles    :generic
    #     # clazz.should include_module 'Roles::Generic'
    #     clazz.should inherit_from :user
    #   end        
    # end # it
  end # desc
end