# Cream

This project aims to assist you in setting up a complete user login and role permission system for your Rails 3 app.
It targets Devise as the user/login system and cancan as the permission system and my own role systems, all integrated in a powerful, yet flexible solution.

## Status

The current version should work as is. The permission system can be integrated nicely with the *roles* gems (see below).
Generators still need some work.

Renamed the old 'auth-assistant' project to this project called 'cream'. 

## Session systems

Cream targets [Devise](http://github.com/plataformatec/devise) as the Session system of choice

* [devise](http://github.com/plataformatec/devise) 

### Devise links

The project [devise links](http://github.com/kristianmandrup/devise-links) adds convenience wrappes for creating links to Devise session actions.

## Roles

I have developed a flexible *Generic Roles* strategy system.

* [Generic Role Strategies](http://github.com/kristianmandrup/roles_generic)

Roles for popular ORMs

* [Roles Active Record](http://github.com/kristianmandrup/roles_active_record)
* [Roles DataMapper](http://github.com/kristianmandrup/roles_data_mapper)
* [Roles MongoMapper](http://github.com/kristianmandrup/roles_mongo_mapper)
* [Roles Mongoid](http://github.com/kristianmandrup/roles_for_mongoid)

_Role Groups_
Document DBs such as *Mongo* and *Riak* are good for modeling a role-group hierarchical relationship. 
Role-Group support is planned as a future add-on for the roles strategies integration. (Any assistance appreciated!)

_Note:_
You are most welcome to provide "plugins" for any other role frameworks. Please follow the API conventions of Roles generic.

## Permission systems 

There will be support for multiple permission systems:

* [CanCan](http://github.com/ryanb/cancan) - currently supported
* [Canable](http://github.com/jnunemaker/canable) - future support?

_Note:_
You are most welcome to provide "plugins" for other permission frameworks.

## ORMs

In general, it should now finally be pretty easy to set up a Rails 3 app, with a full Session system, Permission system linked to a Role strategy system using any ORM. Devise supports the following ORMS:

* Active Record
* Data Mapper
* Mongo Mapper
* Mongoid

These ORMs are also supported for the Roles strategy system. The Permission system should not have any ORM dependency.
There are plans to create a top-level generator which sets up your project with all these systems for a given ORM.

## Installation and configuration ##

This gem has been designed for Rails 3 only.

### Install gems

Insert <pre>gem 'cream'</pre> in your Rails 3 Gemfile
<pre>$ bundle install</pre>

### Install as plugin

In the near future...

<code>rails plugin install http://github.com/kristianmandrup/cream.git</code>

## Role strategies ##

Role strategies can be set up using the [Generic Role Strategies](http://github.com/kristianmandrup/roles_generic) gem or any of the ORM specific roles gems such as [Roles for Active Record](http://github.com/kristianmandrup/roles_active_record). 

_Future plans:_
I have plans to have the main *Cream* generator configure a role strategy of choice for the ORM of choice. 

## Permits

Currently only CanCan is supported as the permission system. 

[Cancan permits](http://github.com/kristianmandrup/cancan-permits)

### CanCan

Role based authorization for [CanCan](http://github.com/ryanb/cancan) is setup by creating 'permits' for each kind of role. 
A *permit* lets a user in a given role do certain actions. 

The *config* generator generates a default <code>permits.rb</code> file which is placed in /lib, which you can edit to suit your needs.

The project [CanCan REST links](http://github.com/kristianmandrup/cancan-rest-links) provides a convenient way to handle CanCan REST links, using a flexible API.

### Canable

In [Canable](http://github.com/jnunemaker/canable) the permissions are by default defined in the models. 
I plan to tweak this behavior to enable the same or a similar central permission setup as I use for CanCan.
My current branch of *Canable* contains generators to setup the models and user with a *Canable* config. 
More to follow in the future...

## Generators

The following generators are currently available 

* config - Configure Rails 3 application with devise Session strategies, a Role strategy, valid roles, and Permits
* views  - Generate partials to display menu items for Session actions such as logout, login etc. 

The *config* generator should automatically setup up your project with Devise, a Roles strategy of choice a Permission system of choice and all using an ORM of your choice! 

Cream will support these ORMs:

* Mongo Mapper
* Mongoid 
* Data Mapper
* Acive Record

_NOTE_: Generators need more testing. The latest *generator-spec* and other supporting utils I've created should make it a breeze... ;)

Just updated the config generator, which is now called 'cream'. The goal is to make it setup appropriate gems in the project and run various generators to create a full, compatible integration of all the systems (devise, cancan, permissions and roles).
Testing of generators to be done ASAP.  

### Config Generator ###

<code>rails g cream::config ROLE_STRATEGY [--devise] [--admin] [--orm]</code>

* --devise  : run devise configure generator
* --admin   : create admin user
* --orm     : orm to be used

Example

<code>rails g cream:config admin_flag --devise --admin --orm AR</code>

### Views Generator ###

Moves 'user menu' partials views into app/views/_user_menu

<code>rails g cream::views [scope] [--haml]</code>

* scope  : The scope folder under views to copy the partials to, fx 'admin'
* --haml : Use HAML as template language

## Note on Patches/Pull Requests ##
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright ##

Copyright (c) 2010 Kristian Mandrup. See LICENSE for details.
