begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "cream"
    gem.summary = %Q{Integrates Devise, Roles and CanCan with Permits for a Rails 3 app}
    gem.description = %Q{Provides assistance for setting up Session, Role and Permission systems for a Rails 3 app. Support for multiple ORMs}
    gem.email = "kmandrup@gmail.com"
    gem.homepage = "http://github.com/kristianmandrup/devise-assistant"
    gem.authors = ["Kristian Mandrup"]

    gem.add_development_dependency "rspec",             "~> 2.0.0.beta.22" 
    gem.add_development_dependency "generator-spec",    "~> 0.6.5" 
    gem.add_development_dependency "rspec-action_view", "~> 0.3.1"     
    gem.add_development_dependency "rails-app-spec",    "~> 0.2.14"

    gem.add_dependency "require_all",       "~> 1.2.0"
    
    gem.add_dependency "devise-links",      "~> 0.1.4"
    gem.add_dependency "cancan-rest-links", "~> 0.1.3" 
    gem.add_dependency "cancan-permits",    "~> 0.1.3" 

    gem.add_dependency "devise",            ">= 1.1.2"
    gem.add_dependency "cancan",            "~> 1.3.4" 
    gem.add_dependency "rails",             "~> 3.0.0"

    gem.add_dependency "rails3_artifactor", "~> 0.2.5"
    gem.add_dependency 'logging_assist',    "~> 0.1.3"

    gem.add_dependency "r3_plugin_toolbox", "~> 0.3.6" 
    gem.add_dependency "sugar-high",        "~> 0.2.10"
           
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
    
    # add more gem options here    
  end    
  Jeweler::GemcutterTasks.new  
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

