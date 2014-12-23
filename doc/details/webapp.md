@title = 'LEAP Web'
@summary = 'The web component of the LEAP Platform, providing user management, support desk, documentation and more.'
@toc = true

Introduction
===================

"LEAP Web" is the webapp component of the LEAP Platform, providing the following services:

* REST API for user registration.
* Admin interface to manage users.
* Client certificate distribution and renewal.
* User support help tickets.
* Billing
* Customizable and Localized user documentation

This web application is written in Ruby on Rails 3, using CouchDB as the backend data store.

It is licensed under the GNU Affero General Public License (version 3.0 or higher). See http://www.gnu.org/licenses/agpl-3.0.html for more information.

Known problems
====================

* Client certificates are generated without a CSR. The problem is that this makes the web
  application extremely vulnerable to denial of service attacks. This was not an issue until we
  started to allow the possibility of anonymously fetching a client certificate without
  authenticating first.

* By its very nature, the user database is vulnerable to enumeration attacks. These are
  very hard to prevent, because our protocol is designed to allow query of a user database via
  proxy in order to provide network perspective.

Integration
===========

LEAP web is part of the leap platform. Most of the time it will be customized and deployed in that context. This section describes the integration of LEAP web in the wider framework. The Development section focusses on development of LEAP web itself.

Configuration & Customization
------------------------------

The customization of the webapp for a leap provider happens via two means:
 * configuration settings in services/webapp.json
 * custom files in files/webapp

### Configuration Settings

The webapp ships with a fairly large set of default settings for all environments. They are stored in config/defaults.yml. During deploy the platform creates config/config.yml from the settings in services/webapp.json. These settings will overwrite the defaults.

### Custom Files

Any file placed in files/webapp in the providers repository will overwrite the content of config/customization in the webapp. These files will override files of the same name.

This mechanism allows customizing basically all aspects of the webapp.
See files/webapp/README.md in the providers repository for more.

### Provider Information ###

The leap client fetches provider information via json files from the server. The platform prepares that information and stores it in the webapp in public/1/config/*.json. (1 being the current API version).

Provider Documentation
-------------

LEAP web already comes with a bit of user documentation. It mostly resides in app/views/pages and thus can be overwritten by adding files to files/webapp/views/pages in the provider repository. You probably want to add your own Terms of Services and Privacy Policy here.
The webapp will render haml, erb and markdown templates and pick translated content from localized files such as privacy_policy.es.md. In order to add or remove languages you have to modify the available_locales setting in the config. (See Configuration Settings above)

Development
===========

Installation
---------------------------

Typically, this application is installed automatically as part of the LEAP Platform. To install it manually for testing or development, follow these instructions:

### TL;DR ###

Install git, ruby 1.9, rubygems and couchdb on your system. Then run

    gem install bundler
    git clone https://leap.se/git/leap_web
    cd leap_web
    git submodule update --init
    bundle install --binstubs
    bin/rails server

### Install system requirements

First of all you need to install ruby, git and couchdb. On debian based systems this would be achieved by something like

    sudo apt-get install git ruby1.9.3 rubygems couchdb

We install most gems we depend upon through [bundler](http://gembundler.com). So first install bundler

    sudo gem install bundler

On Debian Wheezy or later, there is a Debian package for bundler, so you can alternately run ``sudo apt-get install bundler``.

### Download source

Simply clone the git repository:

    git clone git://leap.se/leap_web
    cd leap_web

### SRP Submodule

We currently use a git submodule to include srp-js. This will soon be replaced by a ruby gem. but for now you need to run

  git submodule update --init

### Install required ruby libraries

    cd leap_web
    bundle

Typically, you run ``bundle`` as a normal user and it will ask you for a sudo password when it is time to install the required gems. If you don't have sudo, run ``bundle`` as root.

Configuration
----------------------------

The configuration file `config/defaults.yml` providers good defaults for most
values. You can override these defaults by creating a file `config/config.yml`.

There are a few values you should make sure to modify:

    production:
      admins: ["myusername","otherusername"]
      domain: example.net
      force_ssl: true
      secret_token: "4be2f60fafaf615bd4a13b96bfccf2c2c905898dad34..."
      client_ca_key: "/etc/ssl/ca.key"
      client_ca_cert: "/etc/ssl/ca.crt"
      ca_key_password: nil

* `admins` is an array of usernames that are granted special admin privilege.
* `domain` is your fully qualified domain name.
* `force_ssl`, if set to true, will require secure cookies and turn on HSTS. Don't do this if you are using a self-signed server certificate.
* `secret_token`, used for cookie security, you can create one with `rake secret`. Should be at least 30 characters.
* `client_ca_key`, the private key of the CA used to generate client certificates.
* `client_ca_cert`, the public certificate the CA used to generate client certificates.
* `ca_key_password`, used to unlock the client_ca_key, if needed.

### Provider Settings

The leap client fetches provider information via json files from the server. 
If you want to use that functionality please add your provider files the public/1/config directory. (1 being the current API version).

Running
-----------------------------

    cd leap_web
    bin/rails server

You will find Leap Web running on `localhost:3000`

Testing
--------------------------------

To run all tests

    rake test

To run an individual test:

    rake test TEST=certs/test/unit/client_certificate_test.rb
    or
    ruby -Itest certs/test/unit/client_certificate_test.rb

Engines
---------------------

Leap Web includes some Engines. All things in `app` will overwrite the engine behaviour. You can clone the leap web repository and add your customizations to the `app` directory. Including leap_web as a gem is currently not supported. It should not require too much work though and we would be happy to include the changes required.

If you have no use for one of the engines you can remove it from the Gemfile. Engines should really be plugins - no other engines should depend upon them. If you need functionality in different engines it should probably go into the toplevel.

# Deployment #

We strongly recommend using the LEAP platform for deploy. Most of the things documented here are automated as part of the platform. If you want to research how the platform deploys or work on your own mechanism this section is for you.

These instructions are targeting a Debian GNU/Linux system. You might need to change the commands to match your own needs.

## Server Preperation ##

### Dependencies ##

The following packages need to be installed:

* git
* ruby1.9
* rubygems1.9
* couchdb (if you want to use a local couch)

### Setup Capistrano ###

We use puppet to deploy. But we also ship an untested config/deploy.rb.example. Edit it to match your needs if you want to use capistrano.

run `cap deploy:setup` to create the directory structure.

run `cap deploy` to deploy to the server.

## Customized Files ##

Please make sure your deploy includes the following files:

* public/1/config/*.json (see Provider Settings section)
* config/couchdb.yml

## Couch Security ##

We recommend against using an admin user for running the webapp. To avoid this couch design documents need to be created ahead of time and the auto update mechanism needs to be disabled.
Take a look at test/setup_couch.sh for an example of securing the couch.

## Design Documents ##

After securing the couch design documents need to be deployed with admin permissions. There are two ways of doing this:
 * rake couchrest:migrate_with_proxies
 * dump the documents as files with `rake couchrest:dump` and deploy them
   to the couch by hand or with the platform.

### CouchRest::Migrate ###

The before_script block in .travis.yml illustrates how to do this:

    mv test/config/couchdb.yml.admin config/couchdb.yml  # use admin privileges
    bundle exec rake couchrest:migrate_with_proxies      # run the migrations
    bundle exec rake couchrest:migrate_with_proxies      # looks like this needs to run twice
    mv test/config/couchdb.yml.user config/couchdb.yml   # drop admin privileges

### Deploy design docs from CouchRest::Dump ###

First of all we get the design docs as files:

    # put design docs in /tmp/design
    bundle exec rake couchrest:dump

Then we add them to files/design in the site_couchdb module in leap_platform so they get deployed with the couch. You could also upload them using curl or sth. similar.

# Troubleshooting #

Here are some less common issues you might run into when installing Leap Web.

## Cannot find Bundler ##

### Error Messages ###

`bundle: command not found`

### Solution ###

Make sure bundler is installed. `gem list bundler` should list `bundler`.
You also need to be able to access the `bundler` executable in your PATH.

## Outdated version of rubygems ##

### Error Messages ###

`bundler requires rubygems >= 1.3.6`

### Solution ###

`gem update --system` will install the latest rubygems

## Missing development tools ##

Some required gems will compile C extensions. They need a bunch of utils for this.

### Error Messages ###

`make: Command not found`

### Solution ###

Install the required tools. For linux the `build-essential` package provides most of them. For Mac OS you probably want the XCode Commandline tools.

## Missing libraries and headers ##

Some gem dependencies might not compile because they lack the needed c libraries.

### Solution ###

Install the libraries in question including their development files.


