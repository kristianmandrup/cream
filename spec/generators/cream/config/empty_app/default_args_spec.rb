require 'generator_spec_helper'
require_generator :cream => :config

LOGFILE = File.expand_path File.dirname(__FILE__) + '/../../config_generator-default.log'

puts "Logfile at: #{LOGFILE}"

describe 'role strategy generator: admin_flag' do
  use_helpers :model, :controller, :permit, :files, :file  
  
  before :each do              
    setup_generator 'roles_generator' do
      tests Cream::Generators::ConfigGenerator
    end    
    remove_all_permits
    remove_locale :cream if locale_file? :cream
    
    File.remove_from controller_file(:application) do
          %{
  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = exception.message
    redirect_to root_url
  end
}
    end if controller_file? :application
  end

  after :each do
    remove_all_permits
  end

  describe "Configure Rails 3 app with Cream using default options" do
    before do    
      puts "Running generator"
      Dir.chdir Rails.root do
        @generator = with_generator do |g|
          arguments = "--strategy admin_flag --logfile #{LOGFILE}".args 
          puts "arguments: #{arguments}"
          g.run_generator arguments
        end
      end
    end # before
      
    it "should generate a Devise User with only a :guest role using :role_string strategy" do
      @generator.should_not generate_model :user
      @generator.should have_gems :devise, :cancan, :roles_active_record
    end # it
  end # desc  
end # desc


