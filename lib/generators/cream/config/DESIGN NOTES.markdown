# Config generator

Each of the following should be a module in its own right!

1. Create fresh Rails 3 app and set it up so that all the sub-systems work
2. Develop the generator so that it can mutate a Rails 3 app that matches this example app

## Code Design

* Create a module for each sub-system to configure
* Include modules depending on options
* For each module call the config_[module_name] method, which is responsible for configuring that module! 

## Devise Configuration

Gemfile
gem 'devise' 
gem ORM 'devise'

if app does NOT have a User model
  run devise generator to create User model
else
  if User model is NOT configured with devise strategy
    insert default devise User strategy
  end    
end

if --admin option set 
  if app does NOT have a Admin model
    run devise generator to create Admin model  
    remove any current inheritance
    and make Admin model inherit from User model 
  else
    insert default devise Admin strategy    
  end
end

## Cream configuration

copy locales and views (optional)

## CanCan Configuration

Gemfile:
gem 'cancan'  
gem 'cancan-rest-links' 

CanCan access denied exception handling

## Permits Configuration

Gemfile:
gem 'cancan-permits'

Run permits generator to generate permit for each role

## Roles Configuration

gem ORM 'roles'

run roles generator for ORM chosen 
