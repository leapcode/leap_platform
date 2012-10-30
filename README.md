Leap Platform
=============

What is it?
-----------

The LEAP Provider Platform is the server-side part of the LEAP Encryption Access Project that is run by service providers. It consists of a set of complementary packages and recipes to automate the maintenance of LEAP services in a hardened GNU/Linux environment. LEAP makes it easy and straightforward for service providers and ISPs to deploy a secure communications platform for their users.

The LEAP Platform is essentially a git repository of puppet recipes, with a few scripts to help with bootstrapping and deployment. A service provider who wants to deploy LEAP services will clone or fork this repository, edit the main configuration file to specify which services should run on which hosts, and run scripts to deploy this configuration.

Documentation
-------------
Most of the current documentation can be found in Readme files of the different pieces. Eventually this will be consolidated on the website https://leap.se

Requirements
------------
This highly depends on your (expected) user base. For a minimal test or develop install we recommend a fairly recent computer x86_64 with hardware virtualization features (AMD-V or VT-x) with plenty of RAM. You could use Vagrant or KVM to simulate a live deployment.

For a live deployment of the platform the amount of required (virtual) servers depends on your needs and which services you want to deploy. In it's initial release you can deploy OpenVPN, DNS, CouchDB and a webapp to administer your users (billing, help tickets,...).

To get started you will need to have git, ruby1.8, rails, rubygems, bundler, ruby1.8-dev, libgpgme-ruby. 

Configuration
-------------
Edit config/


Installation
------------

- Edit /etc/leap/hieradata/common.yaml for your needs
- Run the deploy.sh script as root

git clone git://code.leap.se/leap_platform
git clone git://code.leap.se/leap_cli

    cd leap_cli

    bundle

    cd ..

git clone git://code.leap.se/leap_testprovider
ln -s /home/me/dev/leap_cli/bin ~/bin   # or whatever to have leap_cli/bin/leap in your path.
cd leap_testprovider
ln -s ../leap_platform .
cd leap_testprovider/provider
leap help
leap clean
leap compile
leap add-user --self

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


Authors and Credits
------------------

a file manifest

