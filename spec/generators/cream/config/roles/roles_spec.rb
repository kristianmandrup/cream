require 'generator_spec_helper'
require_generator :cream => :config

LOGFILE = File.expand_path File.dirname(__FILE__) + '/../../config_generator-roles.log'

describe 'role strategy generator: admin_flag' do
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
          arguments = "--strategy role_string --init-devise --roles editor author --logfile #{LOGFILE}".args 
          puts "arguments: #{arguments}"
          g.run_generator arguments
        end
      end
    end # before
      
    it "should generate a Devise User with only a :guest role using :role_string strategy" do

      # Devise User with Roles setup
      @generator.should generate_model :user do |clazz|
        clazz.should have_devise_options :defaults
        clazz.should use_roles :generic
        clazz.should include_module 'Roles::ActiveRecord'
        clazz.should have_call :valid_roles_are, :args => ':admin, :guest, :editor, :author'
        clazz.should have_call :role_strategy,  :args => ":role_string"
      end
      
      # Gemfile
      @generator.should have_gems :devise, :cancan, :roles_active_record

      # Permissions
      @generator.should generate_permits :admin, :guest, :editor, :author      
    end # it    
  end # desc
end