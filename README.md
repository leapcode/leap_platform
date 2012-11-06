=============
Leap Platform
=============

What is it?
===========

The LEAP Provider Platform is the server-side part of the LEAP Encryption Access Project that is run by service providers. It consists of a set of complementary packages and recipes to automate the maintenance of LEAP services in a hardened GNU/Linux environment. LEAP makes it easy and straightforward for service providers and ISPs to deploy a secure communications platform for their users.

The LEAP Platform is essentially a git repository of puppet recipes, with a few scripts to help with bootstrapping and deployment. A service provider who wants to deploy LEAP services will clone or fork this repository, edit the main configuration file to specify which services should run on which hosts, and run scripts to deploy this configuration.

Documentation
=============

Most of the current documentation can be found in Readme files of the different pieces. Eventually this will be consolidated on the website https://leap.se

Requirements
============

This highly depends on your (expected) user base. 
For a minimal test or develop install we recommend a fairly recent computer x86_64 with hardware virtualization features (AMD-V or VT-x) with plenty of RAM. You could use Vagrant or KVM to simulate a live deployment.

For a live deployment of the platform the amount of required (virtual) servers depends on your needs and which services you want to deploy. 
In it's initial release you can deploy OpenVPN, CouchDB and a webapp to administer your users (billing, help tickets,...).
While you can deploy all services on one server, we stronly recommend to use seperate servers for better security.

To get started you will need to have git, ruby1.8, rails, rubygems, bundler, ruby1.8-dev, libgpgme-ruby. 


Installation
============

Create a working directory
--------------------------

  mkdir ~/Leap
  cd ~/Leap 

Install leap_cli
----------------

  git clone git://code.leap.se/leap_cli
  cd leap_cli

See also README.md for installation hints, but this should work in most cases:

  bundle
  rake build
  rake install
  leap help

Install leap_platform
---------------------

  cd ~/Leap
  git clone git://code.leap.se/leap_platform
  cd leap_platform
  
Right now, use the develop branch

  git checkout develop

Initialize Submodules

  git submodule init
  git submodule update

Configuration
=============

Create config file templates 
----------------------------

  cd ~/Leap
  leap init-provider vagrant_test
  cd vagrant_test

Configure 
---------

Edit following files: 
  
  * common.yaml
  * nodes/COUCHDB_SERVER.yaml
  * nodes/WEBAPP_SERVER.yaml
  * nodes/VPN_SERVER.yaml
 
  leap add-user --self
  leap compile

Initialize and deploy nodes
---------------------------

For every server you configured do:
  
  leap node-init SERVERNAME
  leap -v 2 deploy SERVERNAME

More Information
----------------
For more information about the LEAP Encryption Access Project, please visit the website https://leap.se which also lists contact data.


Following needs to be written:

Copyright/License
-----------------

Read LICENSE

Known bugs
----------

Troubleshooting
---------------

Changelog
---------

For a changelog of the current branch:

  cd ~/Leap
  git log 

Authors and Credits
------------------

a file manifest

