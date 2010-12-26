# Cream

This project aims to assist you in setting up a complete Authentication and Authorization system for your Rails 3 app and supports multiple ORMs.
Just run the *full_config* generator with arguments specifying: roles available, the role strategy to use and the ORM to target and you are set to go.

_Note_: Cream leverages an extensive set of framework components I have created specifically to make it much easier/faster to create Rails 3 plugins and spec/test them, using more natural DSLs. Look into the code to see the magic!

Cream targets smooth integration of the following systems:

* [Devise](http://github.com/plataformatec/devise) - Authentication
* [CanCan](http://github.com/ryanb/cancan) - Authorization
* [Roles Generic](http://github.com/kristianmandrup/roles_generic) - Roles

For more advanced Authorization configuration, cream uses *cancan-permits* to enable use of *Permits* and *Licenses*.
The gems *devise-links* and *cancan-rest-links* provide view helpers to facilitate working with authentication links and to enable REST links with permission logic.
Cream itself provides generators to easily configure your Rails 3 app with these gems and also includes various view and controller helpers to guard specific view and/or controller logic with permission requirements. Cream targets a set of common ORMs for Rails for Relational and Document based datastores. 

The objectives of this project:

* Integrate all these sub-systems
* Provide generators that can auto-configure your Rails 3 app with these systems for a given ORM

For more information also see the [Cream Wiki](https://github.com/kristianmandrup/cream/wiki), which includes Cream status notes and a complete listing and usage examples of the latest Roles Generic API. There is now also an overview of the full Cream API, which contains various helper methods to facilitate working with users, sessions, roles and permissions in both your views and controllers. Please let me know of other areas that you think should be covered in the Wiki or on this main page ;) 

## Cream user group

The [Cream user group](http://groups.google.com/group/rails-cream) is a google group where you can ask Cream related questions, provide suggestions etc. to the Cream community.

## Rails 3 demo apps with Cream

The following Rails 3 demo apps use Cream 0.7.7 and above and were created around Dec 1. 2010

* [Cream app with Active Record](https://github.com/kristianmandrup/cream-app-active_record) 
* [Cream app with Mongoid](https://github.com/kristianmandrup/cream-app-mongoid) 
* [Cream app with Mongo Mapper](https://github.com/kristianmandrup/cream-app-mongo_mapper) 

## Authentication systems

Cream targets [devise](http://github.com/plataformatec/devise) as the Authentication system of choice

### Devise links

The project [devise links](http://github.com/kristianmandrup/devise-links) adds more convenience for creating view links to trigger Devise session actions.

## Authorization system

There is support for the [CanCan](http://github.com/ryanb/cancan) Authorization system. 
I have created a [Cancan permits](http://github.com/kristianmandrup/cancan-permits) gem that adds the concept of Permits for each role (see below).

## Roles

I have developed a flexible [Roles Generic](http://github.com/kristianmandrup/roles_generic) system which is used as the basis for the default Role system.

The *Roles Generic API* has been implemented for the following ORMs

* [Roles Active Record](http://github.com/kristianmandrup/roles_active_record)
* [Roles DataMapper](http://github.com/kristianmandrup/roles_data_mapper)
* [Roles MongoMapper](http://github.com/kristianmandrup/roles_mongo_mapper)
* [Roles Mongoid](http://github.com/kristianmandrup/roles_for_mongoid)
* [Roles Simply Stored](https://github.com/kristianmandrup/roles_simply_stored)

_Note_: Any role system can be substituted as long as you have a method #has_role? on the user which returns true or false given a string or symbol that identifies the role.

### Role Groups

Document DBs such as *Mongo* and *Riak* are ideal for modeling a role-group hierarchical relationship. 
Role-Group support is planned as a future add-on for the roles strategies integration. (Any assistance appreciated!)

## ORMs

In general, it should now finally be pretty easy to set up a Rails 3 app, with a full Authentication and an Authorization system linked to a Role system using one of the following supported Cream ORMs. 

Relational Databases:

* Active Record
* Data Mapper

Document stores:

* Mongo Mapper
* Mongoid
* Couch DB

These ORMs are also supported for the *CanCan Permits* and *Roles* systems. 

## Installation and configuration ##

This gem has been designed for Rails 3 and Ruby 1.9 only. Some users have notified me that it doesn't work on Ruby 1.8.7, so be advised!

### Install gems

Insert <pre>gem 'cream'</pre> in your Rails 3 Gemfile
<pre>$ bundle install</pre>

## Role system

Role strategies can be set up using the [Roles Generic](http://github.com/kristianmandrup/roles_generic) gem or any of the ORM specific roles gems such as [Roles Active Record](http://github.com/kristianmandrup/roles_active_record). 

## CanCan

Role based authorization for [CanCan](http://github.com/ryanb/cancan) can be achieved by creating a *Permit* class for each role. 

### Permits

A *Permit* lets a user in a given role do certain actions as defined in the Permit. 
A Permit can also reuse permission logic in the form of Licenses for a more fine grained design if needed. 

CanCan Permits comes with generators to generate Permit files which are placed in '/app/permits'. You can then edit the Permits to suit your needs.

The project [CanCan REST links](http://github.com/kristianmandrup/cancan-rest-links) provides a convenient way to handle CanCan REST links, using a flexible API.

Check out [Cancan permits](http://github.com/kristianmandrup/cancan-permits) for more info for how to use Permits.

*Cancan permits* support all the ORMs that both Devise and Roles support.

### Permits Editor

I have recently created a [Permits editor](http://github.com/kristianmandrup/permits_editor) application that demonstrates how you can let the user edit the Permits, Licenses and even individual User permissions directly as part of an admin section of the web app. The *Permits editor* updates yaml files that are now part of the *cancan-permits* infrastructure (if present and registered). I plan to refactor the Permits Editor into a [mountable app](http://piotrsarnacki.com/2010/12/21/mountable-apps-tutorial/) when I have the time.

### Licenses

For more advanced authorization scenarios you can create reusable permission logic in license classed that are placed in '/app/licenses/'. A License can be reused in multiple Permits. 

See [CanCan permits demo app](https://github.com/kristianmandrup/cancan-permits-demo) for an example of how to use cancan-permits and licenses.

## Generators

The following generators are currently available:

Main generator: 

* cream:full_config    - Configure Rails 3 application with Cream (master generator)

Config generators:

* devise:config   - Configure Rails 3 application with Devise
* devise:users    - Configure Rails 3 application with Devise users
* cancan:config   - Configures app with CanCan
* permits:config  - Configures app with CanCan Permits
* roles:config    - Configures app with Roles

Other generators:

* cancan:restlinks - Create REST links locale file 
* devise:links - Create devise links locale file (should I rename this to authlinks?)
* cream:views - Generates partials for menu items (outdated)

All the above generators have specs included in cream that demonstrate how to use them and should verify that they work as expected.

In general, the *cream:full_config* generator can be seen as a kind of "super generator", in that it should call all the sub-generators in succession to fully configure
the Rails 3 app in one go. 

### Full Config Generator ###

Master cream generator which calls the sub-generators in succession.

<code>rails g cream:full_config --strategy ROLE_STRATEGY [--admin_user] [--orm ORM] [--roles ROLE1 ROLE2] [--logfile LOGFILE]</code>

* --strategy      : role strategy to use (see *roles_generic* gem)
* --admin-user    : create admin user model with separate devise configuration
* --orm           : orm to be used
* --roles         : list of valid roles and permits to use

Example

<code>rails g cream:full_config --strategy admin_flag --admin-user --orm AR</code>

By default creates :guest and :admin roles.

## Sub generators

To view the run options of any of the sub generators, simply type $ rails g [GENERATOR_NAME]

Example: <code>rails g permits:config</code>

### Cream Views Generator ###

Moves 'user menu' partials views into app/views/_user_menu

<code>rails g cream:views [scope] [--haml]</code>

* scope  : The scope folder under views to copy the partials to, fx 'admin'
* --haml : Use HAML as template language

_Note_: This *views* generator is based on a similar generator from the devise project. It might be removed in the near future as these menu items would make more sense as simple view helpers (suggestions?).

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
