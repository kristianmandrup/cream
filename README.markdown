# Cream

This project aims to assist you in setting up a complete user login and role permission system for your Rails 3 app.
It targets [Devise](http://github.com/plataformatec/devise) as the Session system, [CanCan](http://github.com/ryanb/cancan) as the permission system and 
[Roles](http://github.com/kristianmandrup/roles_generic) as the user Roles system. 

The objective of this project is to 
* Integrate all these sub-systems
* Provide a generator that can auto-configure your Rails 3 app with these sub-systems for a given ORM

## Status

This project and the gems it assembles should all mostly work. I am currently going through all the supporting gems, making sure dependencies 
are updated and that they use the latest APIs of the other gems and all specs pass. Stay tuned!
The config generators is currently under construction and needs some fine-tuning to bring all the gems together.

I have now also started a new project called [Cream rails 3 app](http://github.com/kristianmandrup/cream-rails3-app) which is to be a template Rails 3 project 
that demonstrates what a final Rails 3 app using Cream will look like. I plan to use this as a template for the Cream config generator, making sure that given
Mongo Mapper as the ORM and default arguments, the generartor should generate a "mirror image" of this template project. You are most welcome to help me in this effort
or provide suggestions etc. The README of the template project will contain a recipe with the steps to be taken to produce it ;)

NOTE: I have renamed the old 'auth-assistant' project to this project called 'cream'. 

## Session systems

Cream targets [Devise](http://github.com/plataformatec/devise) as the Session system of choice

* [devise](http://github.com/plataformatec/devise) 

### Devise links

The project [devise links](http://github.com/kristianmandrup/devise-links) adds more convenience for creating view links to trigger Devise session actions.

## Roles

I have developed a flexible *Generic Roles* strategy system.

* [Generic Role Strategies](http://github.com/kristianmandrup/roles_generic)

Roles for popular ORMs

The Roles Generic API has been implemented for the following ORMs

* [Roles Active Record](http://github.com/kristianmandrup/roles_active_record)
* [Roles DataMapper](http://github.com/kristianmandrup/roles_data_mapper)
* [Roles MongoMapper](http://github.com/kristianmandrup/roles_mongo_mapper)
* [Roles Mongoid](http://github.com/kristianmandrup/roles_for_mongoid)

_Role Groups_
Document DBs such as *Mongo* and *Riak* are good for modeling a role-group hierarchical relationship. 
Role-Group support is planned as a future add-on for the roles strategies integration. (Any assistance appreciated!)

_Note:_
You are most welcome to provide "plugins" for any other role frameworks. Please follow the API conventions of Roles generic.
Update: Currently in the process of expanding the API a little (add, remove, exhange roles) while making it more generic and flexible.

## Permission systems 

There is support for the [CanCan](http://github.com/ryanb/cancan) permission system. 
I have created a [Cancan permits](http://github.com/kristianmandrup/cancan-permits) gem that adds the concept of Permits for each role (see below).

_Note:_
You are most welcome to provide "plugins" for other permission frameworks!

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

## Role system

Role strategies can be set up using the [Roles Generic](http://github.com/kristianmandrup/roles_generic) gem or any of the ORM specific roles gems such as [Roles - Active Record](http://github.com/kristianmandrup/roles_active_record). There are currently Roles implementations for the following ORMs:

* Active Record
* Data Mapper
* Mongo Mapper
* Mongoid

## Permission system 

The only Permission system currently supported is *CanCan*.

### CanCan

Role based authorization for [CanCan](http://github.com/ryanb/cancan) is currently done by creating *Permits* for each role. 
A *Permit* lets a user in a given role do certain actions as defined in the Permit. 

The *config* generator will generate a set of Permit files which are placed in '/app/permits'. You can then edit the Permits to suit your needs.

The project [CanCan REST links](http://github.com/kristianmandrup/cancan-rest-links) provides a convenient way to handle CanCan REST links, using a flexible API.

## Permits

Currently CanCan is supported as the permission system. I have added the concept of Permits (and optionally Licenses) linked to Roles. 

Check out [Cancan permits](http://github.com/kristianmandrup/cancan-permits) for more info for how to use Permits.

Cream has ben updated to support my the version of *Cancan permits*, which now support all the ORMs that both Cream and Roles Generic support.
The various players are starting to play together nice! 

## Generators

The following generators are currently available 

* cream:config    - Configure Rails 3 application with Cream (master generator)

Sub-generators

* cream:views     - Generates partials for menu items
* devise:config   - Configure Rails 3 application with Devise
* devise:users    - Configure Rails 3 application with Devise users
* cancan:config   - Configures app with CanCan
* permits:config  - Configures app with CanCan Permits
* roles:config    - Configures app with Roles

All the above generators now have specs to show how to use them. 
Note: These generators have still not been tested in all scenarios with all ORMs, role strategies etc.
I am sure there are still some issues... so please help uncover these!

In general, the cream:config generator can be seen as a kind of "super generator", in that it should call all the sub-generators in succession to attempt to fully configure
and applicaiton in one go. 

Cream will support these ORMs:

* Active Record
* Data Mapper
* Mongo Mapper
* Mongoid 

### Config Generator ###

Master cream generator which calls the sub-generators in succession.

<code>rails g cream::config --strategy ROLE_STRATEGY [--admin_user] [--orm ORM] [--roles ROLE1 ROLE2] [--logfile LOGFILE]</code>

* --strategy      : role strategy to use (see *roles_generic* gem)
* --admin-user    : create admin user model with separate devise configuration
* --orm           : orm to be used
* --roles         : list of valid roles and permits to use

Example

<code>rails g cream:config --strategy admin_flag --admin-user --orm AR</code>

By default creates :guest and :admin roles.

## Sub generators

To view the run options of any of the sub generators, simply type $ rails g [GENERATOR_NAME]

Example: <code>rails g permits:config</code>

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
