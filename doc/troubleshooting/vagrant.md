@title = 'LEAP Platform Vagrant testing'
@nav_title = 'Vagrant Integration'
@summary = 'Testing your provider with Vagrant'

Setting up Vagrant for a testing the platform
=============================================

There are two ways you can setup leap platform using vagrant.

Using the Vagrantfile provided by Leap Platform
-----------------------------------------------

This is by far the easiest way. It will install a single node mail server in the default
configuration with one single command.

Clone the platform with

    git clone https://github.com/leapcode/leap_platform.git

Start the vagrant box with

    cd leap_platform
    vagrant up

Follow the instructions how to configure your `/etc/hosts`
in order to use the provider!

You can login via ssh with the systemuser `vagrant` and the same password.

There are 2 users preconfigured:

. `testuser`  with pw `hallo123`
. `testadmin` with pw `hallo123`


Use the leap_cli vagrant integration
------------------------------------

Install leap_cli and leap_platform on your host, configure a provider from scratch and use the `leap local` commands to manage your vagrant node(s).

See https://leap.se/en/docs/platform/development how to use the leap_cli vagrant
integration and https://leap.se/en/docs/platform/tutorials/single-node-email how
to setup a single node mail server.


