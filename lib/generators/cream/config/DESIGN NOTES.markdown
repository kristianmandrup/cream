# Config generator

Each of the following should be a module in its own right!

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

None?

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
