begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "cream"
    gem.summary = %Q{Integrates Devise, CanCan with permits and Roles generic for multiple ORMs}
    gem.description = %Q{An integrated Authentication, Authorization and Roles solution for your Rails 3 app with support for multiple ORMs}
    gem.email = "kmandrup@gmail.com"
    gem.homepage = "http://github.com/kristianmandrup/cream"
    gem.authors = ["Kristian Mandrup"]

    gem.add_development_dependency "rspec",             ">= 2.0.1" 
    gem.add_development_dependency "generator-spec",    ">= 0.7.0" 
    gem.add_development_dependency "rspec-action_view", ">= 0.3.1"     
    gem.add_development_dependency "rails-app-spec",    ">= 0.3.0"
    gem.add_development_dependency "devise-spec",       ">= 0.1.3"    
    gem.add_development_dependency "roles-spec",        ">= 0.1.3"    

    gem.add_dependency "require_all",       "~> 1.2.0"
    gem.add_dependency "colorize",          ">= 0.5.8"
    
    gem.add_dependency "devise-links",      ">= 0.2.1"
    gem.add_dependency "cancan-rest-links", ">= 0.2.1" 
    gem.add_dependency "cancan-permits",    ">= 0.3.7" 

    gem.add_dependency "devise",            ">= 1.1.5"
    gem.add_dependency "cancan",            ">= 1.4.0" 
    gem.add_dependency "rails",             ">= 3.0.1"

    gem.add_dependency "rails3_artifactor", "~> 0.3.2"
    gem.add_dependency 'logging_assist',    "~> 0.1.6"

    gem.add_dependency "r3_plugin_toolbox", ">= 0.4.0" 
    gem.add_dependency "sugar-high",        "~> 0.3.1"
           
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
    
    # add more gem options here    
  end    
  Jeweler::GemcutterTasks.new  
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

