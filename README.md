=============
Leap Platform
=============

What is it?
===========

The LEAP Provider Platform is the server-side part of the LEAP Encryption Access Project that is run by service providers. It consists of a set of complementary modules and recipes to automate the maintenance of LEAP services in a hardened GNU/Linux environment. LEAP makes it easy and straightforward for service providers and ISPs to deploy a secure communications platform for their users.

The LEAP Platform is essentially a git repository of puppet recipes, with a few scripts to help with bootstrapping and deployment. A service provider who wants to deploy LEAP services will clone or fork this repository, edit the main configuration file to specify which services should run on which hosts, and run scripts to deploy this configuration.

Documentation
=============

Most of the current documentation can be found in Readme files of the different pieces. This will be consolidated on the website https://leap.se soon.

Requirements
============

This highly depends on your (expected) user base. 
For a minimal test or develop install we recommend a fairly recent computer x86_64 with hardware virtualization features (AMD-V or VT-x) with plenty of RAM. 
You could use Vagrant or KVM to simulate a live deployment.

For a live deployment of the platform the amount of required (virtual) servers depends on your needs and which services you want to deploy. 
In it's initial release you can deploy Tor, OpenVPN, CouchDB and a webapp to administer your users (billing, help tickets,...).
While you can deploy all services on one server, we stronly recommend to use seperate servers for better security.


Usage
=====

As mentioned above, Leap Platform are the server-side Puppet manifests, for deploying a service provider, you need the leap command line interface, 
available here: https://github.com/leapcode/leap_cli

We strongly recommend to follow the `Quick Start` Documentaion which can be found on the website https://leap.se


Clone leap_platform and its submodules
--------------------------------------

    git checkout develop

Initialize Submodules:

    git submodule update --init


More Information
================

For more information about the LEAP Encryption Access Project, please visit the website https://leap.se which also lists contact data.


Copyright/License
-----------------

Read LICENSE


Known bugs
----------

* currently none known, there will probably be some around !

Troubleshooting
---------------

Visit https://leap.se/en/development for contact possibilities.

Changelog
---------

For a changelog of the current branch:

    git log 

Authors and Credits
------------------

See contributors: 

    git shortlog -es --all

