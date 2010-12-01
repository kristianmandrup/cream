# Cream

This project aims to assist you in setting up a complete Authentication and Authorization system for your Rails 3 app.

It targets

* [Devise](http://github.com/plataformatec/devise) - Authorization
* [CanCan](http://github.com/ryanb/cancan) - Authentication
* [Roles Generic](http://github.com/kristianmandrup/roles_generic) - Roles

For more advanced Authorization configuration, cream uses cancan-permits to enabel use of Permits and Licenses.
The gems *devise-links* and *cancan-rest-links* provide view helpers to facilitate working with authentication links and model REST links with permission logic.
Cream itself provides generators to easily configure your Rails 3 app with these gems and also includes various view and controller helpers to guard view or controller logic. The project targets a collection of common ORMs for Rails, for both Relational and Document based datastores. 

The objective of this project is to 

* Integrate all these sub-systems
* Provide generators that can auto-configure your Rails 3 app with these sub-systems for a given ORM

_UPDATE_: 1. Dec 2010
Rhe 'full_config' generator ha snow been tested in a fresh Rails 3.0.3 app and works with the following orms:
* active_record
* mongoid

I will shortly go through the other ORMs and create Rails 3 demo apps for each with instructions.

## Rails 3 demo apps with Cream

The following Rails 3 demo apps use Cream 0.7.7 and above and were created Dec 1. 2010

* [Cream app with Active Record](https://github.com/kristianmandrup/cream-app-active_record) 
* [Cream app with Mongoid](https://github.com/kristianmandrup/cream-app-mongoid) 
* [Cream app with Mongo Mapper](https://github.com/kristianmandrup/cream-app-mongo_mapper) 

## Status

[CanCan permits demo](https://github.com/kristianmandrup/cancan-permits-demo) is a recent Rails 3 app I created to demonstrate configuration of a Rails 3 app using
*cancan-permits* and *cancan-rest-links*. I will build on this in the near future to provide a full Rails 3 app with all the cream features enabled. 
Stay tuned! Or even better, help me create such template/tutorial projects ;)

### Update Nov 28, 2010

Finally cream again installs from a clean base without any dependency problems :) I just switched to Ruby 1.9.3-dev and tested cream from a clean ruby gems.

## Authentication systems

Cream targets [Devise](http://github.com/plataformatec/devise) as the Authentication system of choice

* [devise](http://github.com/plataformatec/devise) 

### Devise links

The project [devise links](http://github.com/kristianmandrup/devise-links) adds more convenience for creating view links to trigger Devise session actions.

## Authorization system

There is support for the [CanCan](http://github.com/ryanb/cancan) Authorization system. 
I have created a [Cancan permits](http://github.com/kristianmandrup/cancan-permits) gem that adds the concept of Permits for each role (see below).

_Note:_
You are most welcome to provide "plugins" for other permission frameworks!

## Roles

I have developed a flexible *Generic Roles* strategy system.

* [Generic Role Strategies](http://github.com/kristianmandrup/roles_generic)

Roles for popular ORMs

The Roles Generic API has been implemented for the following ORMs

* [Roles Active Record](http://github.com/kristianmandrup/roles_active_record)
* [Roles DataMapper](http://github.com/kristianmandrup/roles_data_mapper)
* [Roles MongoMapper](http://github.com/kristianmandrup/roles_mongo_mapper)
* [Roles Mongoid](http://github.com/kristianmandrup/roles_for_mongoid)
* [Roles Mongoid](http://github.com/kristianmandrup/roles_for_mongoid)
* [Roles Simply Stored](https://github.com/kristianmandrup/roles_simply_stored)

_Role Groups_
Document DBs such as *Mongo* and *Riak* are good for modeling a role-group hierarchical relationship. 
Role-Group support is planned as a future add-on for the roles strategies integration. (Any assistance appreciated!)

_Note:_
You are most welcome to provide "plugins" for any other role frameworks. Please follow the API conventions of Roles generic.

_Update:_
Roles Generic has recently been upgraded with a better API, architecture, framework for testing and more and better functionality. It should also now be more DRY and
easier/simpler to add more strategies and Datastore adapters.

## ORMs

In general, it should now finally be pretty easy to set up a Rails 3 app, with a full Authentication and an Authorization system linked to a Role system using one of the following supported Cream ORMs. 

Relational DB:
* Active Record
* Data Mapper

Document datastores:
* Mongo DB
** Mongo Mapper
** Mongoid
* Couch DB

These ORMs are also supported for the CanCan Permits and Roles systems. 

## Installation and configuration ##

This gem has been designed for Rails 3 only.

### Install gems

Insert <pre>gem 'cream'</pre> in your Rails 3 Gemfile
<pre>$ bundle install</pre>

## Role system

Role strategies can be set up using the [Roles Generic](http://github.com/kristianmandrup/roles_generic) gem or any of the ORM specific roles gems such as [Roles - Active Record](http://github.com/kristianmandrup/roles_active_record). There are currently Roles implementations for the following ORMs:

* Active Record
* Data Mapper
* Mongo Mapper
* Mongoid
* Couch DB (via SimplyStored)

_Note_: 
Roles for SimplyStored is "shaky" and works only with the admin_flag strategy. I won't develop more on this particular ORM adapter until requested to do so.
If you need to use Roles with Couch DB, please help implement this adapter, maybe using another (better?) object-mapping solution for Couch DB.

### Update

The Role systems all ORMs (except SimplyStored which is in progress) have recently been upgraded to take advantage of a new Roles Generic API and archictecture. 

## CanCan

Role based authorization for [CanCan](http://github.com/ryanb/cancan) can be done by creating a *Permit* class for each role. 

### Permits

A *Permit* lets a user in a given role do certain actions as defined in the Permit. 
A Permit can also reuse permission logic in the form of Licenses for a more fine grained design if needed. 

CanCan Permits comes with generators to generate Permit files which are placed in '/app/permits'. You can then edit the Permits to suit your needs.

The project [CanCan REST links](http://github.com/kristianmandrup/cancan-rest-links) provides a convenient way to handle CanCan REST links, using a flexible API.

Check out [Cancan permits](http://github.com/kristianmandrup/cancan-permits) for more info for how to use Permits.

*Cancan permits* support all the ORMs that both Devise and Roles Generic support.

### Licenses

For more advanced authorization scenarios you can create reusable permission logic in license classed that are placed in '/app/licenses/'. A License can be reused in multiple Permits. 

See [CanCan permits demo app](https://github.com/kristianmandrup/cancan-permits-demo) for an example of how to use cancan-permits and licenses.

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

* cancan:restlinks - create REST links locale file 
* devise:links - create devise links locale file (should maybe be renamed authlinks?)

All the above generators have specs included in cream that demonstrate how to use them and should verify that they work as expected. 

In general, the cream:config generator can be seen as a kind of "super generator", in that it should call all the sub-generators in succession to fully configure
the Rails 3 app in one go. I need more people to test this out to see how well it works. I am sure there are still a few bugs and issues here... 

Cream target these ORMs:

Relational DB (SQL)
* Active Record
* Data Mapper

Mongo Mapper (NoSQL Document store)
* Mongo Mapper
* Mongoid 

Couch DB (NoSQL Document store)
* SimplyStored ()

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
