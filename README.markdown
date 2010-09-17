# Cream

This project aims to assist you in setting up a complete user login and role permission system for your Rails 3 app.
It targets [Devise](http://github.com/plataformatec/devise) as the Session system, [CanCan](http://github.com/ryanb/cancan) as the permission system and 
[Roles](http://github.com/kristianmandrup/roles_generic) as the user Roles system. 

The objective of this project is to 
* Integrate all these sub-systems
* Provide a generator that can auto-configure your Rails 3 app with these sub-systems for a given ORM

## Status

This project and the gems it assembles should all work. 
The config generators is currently under construction and needs some fine-tuning to bring all the gems together.

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

## Permission systems 

There is support for the [CanCan](http://github.com/ryanb/cancan) permission system. 
I have created a [Cancan permits](http://github.com/kristianmandrup/cancan-permits) gem that adds the concept of Permits for each role (see below)

I'm considering supporting [Canable](http://github.com/jnunemaker/canable) as well (but only if requested by the community!)

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

### Canable

In [Canable](http://github.com/jnunemaker/canable) the permissions are by default defined in the models. 
I plan to tweak this behavior to enable the same or a similar central permission setup as I use for CanCan.
In my (somewhat old and degenerate) fork of *Canable*, I have generators to setup the models and user with a *Canable* config. 

_Note_: These generators should be updated to take advantage of my latest generator-spec and other supporting generator assitant gems!

More to follow in the future...

## Permits

Currently CanCan is supported as the permission system. I have added the concept of Permits linked to Roles. 

Check out [Cancan permits](http://github.com/kristianmandrup/cancan-permits) for more info for how to use Permits.

_Note_: In the future I will add the ability for a given role to have multiple Permits in a PermitSet, so that Permits are stand-alone and not linked to a given role, which
allows permits to be reused for multiple roles. Stay tuned or join in the effort!

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

Status 17 sept, 2010: 
The latest *generator-spec* and other supporting generator utils I've created (such as rails3_artifactor) should facilitate finishing this generator...

The goal is to make the generator:
* Configure the Rails 3 app with appropriate gems for the sub-systems 
* Run various other generators 

The result should be a full (or nearly full) integration of all the sub-systems mentioned for a given Rails 3 app with the ORM of choice.

### Config Generator ###

<code>rails g cream::config --strategy ROLE_STRATEGY [--init-devise] [--admin_user] [--orm] [--roles]</code>

* --strategy      : role strategy to use (see *roles_generic* gem)
* --init-devise   : run devise generator to create devise Users with session/auth strategies
* --admin-user    : create admin user model with separate devise configuration
* --orm           : orm to be used
* --roles         : list of valid roles to use

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
