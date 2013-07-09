=============
Leap Platform
=============

What is it?
===========

The LEAP Platform is set of complementary packages and server recipes to automate the maintenance of LEAP services in a hardened Debian environment. Its goal is to make it as painless as possible for sysadmins to deploy and maintain a service provider’s infrastructure for secure communication. These recipes define an abstract service provider. It is a set of Puppet modules designed to work together to provide to sysadmins everything they need to manage a service provider infrastructure that provides secure communication services.

As these recipes consist of abstract definitions, in order to configure settings for a particular service provider a system administrator has to obtain the leap command-line interface and create a provider instance. The details of how to get started are contained in the `Quick Start` documentation as detailed below.


Getting started
===============

It is highly recommended that you start by reading the overview of the Leap Platform on the website (https://leap.se/docs/platform) and then begin with the `Quick Start` guide (https://leap.se/docs/platform/quick-start) to walk through a test environment setup to get familiar with how things work before deploying to live servers. 

An offline copy of this documentation is contained in the `doc` subdirectory. For more current updates to the documentation, visit the website.

Requirements
------------

For a minimal test or develop install we recommend a fairly recent computer x86_64 with hardware virtualization features (AMD-V or VT-x) with plenty of RAM. If you follow the `Quick Start` documentation we will walk you through using Vagrant to setup a test deployment.

For a live deployment of the platform the amount of required (virtual) servers depends on your needs and which services you want to deploy. At the moment, the Leap Platform supports servers with a base Debian Wheezy installation.

While you can deploy all services on one server, we stronly recommend to use seperate servers for better security.


Troubleshooting
===============

If you have a problem, we are interested in fixing it! 

If you have a problem, be sure to have a look at the Known Issues section of the documentation to see if your issue is detailed there.

If not, the best way for us to solve your problem is if you provide to us the complete log of what you did, and the output that was produced. Please don't cut out what appears to be useless information and only include the error that you received, instead copy and paste the complete log so that we can better determine the overall situation. If you can run the same command that produced the error with a raised verbosity level (such as -v2), that provides us with more useful debugging information.

Visit https://leap.se/development for contact possibilities.

Known Issues
------------

* Please read the section in the documentation about Known Issues (https://leap.se/docs/platform/known-issues)


More Information
================

For more information about the LEAP Encryption Access Project, please visit the website https://leap.se which also lists contact data.

Changelog
---------

For a changelog of the current branch:

    git log 

Authors and Credits
------------------

See contributors: 

    git shortlog -es --all


Copyright/License
-----------------

Read LICENSE



