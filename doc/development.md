@title = "Development Environment"
@toc = true

If you are wanting to make local changes to your provider, or want to contribute some fixes back to LEAP, we recommend that you follow this guide to build up a development environment to test your changes first. Using this method, you can quickly test your changes without deploying them to your production environment, while benefitting from the convenience of reverting to known good states in order to retry things from scratch. 

This page will walk you through setting up nodes using [Vagrant](http://www.vagrantup.com/) for convenient deployment testing, snapshotting known good states, and reverting to previous snapshots. 

Requirements
============

* Be a real machine with virtualization support in the CPU (VT-x or AMD-V). In other words, not a virtual machine.
* Have at least 4gb of RAM.
* Have a fast internet connection (because you will be downloading a lot of big files, like virtual machine images).

Install prerequisites
--------------------------------

For development purposes, you will need everything that you need for deploying the LEAP platform:

* LEAP cli
* A provider instance

You will also need to setup a virtualized Vagrant environment, to do so please make sure you have the following
pre-requisites installed:

*Debian & Ubuntu*

Install core prerequisites:

    sudo apt-get install git ruby ruby-dev rsync openssh-client openssl rake make

Install Vagrant in order to be able to test with local virtual machines (typically optional, but required for this tutorial):

    sudo apt-get install vagrant virtualbox

<!--
*Mac OS*

1. Install rubygems from https://rubygems.org/pages/download (unless the `gem` command is already installed).
2. Install Vagrant.dmg from http://downloads.vagrantup.com/
-->


Adding development nodes to your provider
=========================================

Now you will add local-only Vagrant development nodes to your provider. 

You do not need to setup a different provider instance for development, in fact it is more convenient if you do not, but you can if you wish.  If you do not have a provider already, you will need to create one and configure it before continuing (it is recommended you go through the [Quick Start](quick-start) before continuing down this path). 


Create local development nodes
------------------------------

We will add "local" nodes, which are special nodes that are used only for testing. These nodes exist only as virtual machines on your computer, and cannot be accessed from the outside. Each "node" is a server that can have one or more services attached to it. We recommend that you create different nodes for different services to better isolate issues.

While in your provider directory, create a local node, with the service "webapp":

    $ leap node add --local web1 services:webapp
     = created nodes/web1.json
     = created files/nodes/web1/
     = created files/nodes/web1/web1.key
     = created files/nodes/web1/web1.crt

This command creates a node configuration file in `nodes/web1.json` with the webapp service. 

Starting local development nodes
--------------------------------

In order to test the node "web1" we need to start it. Starting a node for the first time will spin up a virtual machine. The first time you do this will take some time because it will need to download a VM image (about 700mb). After you've downloaded the base image, you will not need to download it again, and instead you will re-use the downloaded image (until you need to update the image).

NOTE: Many people have difficulties getting Vagrant working. If the following commands do not work, please visit the [Vagrant page](vagrant) to troubleshoot your Vagrant install before proceeding.

    $ leap local start web
     = created test/
     = created test/Vagrantfile
     = installing vagrant plugin 'sahara'
    Bringing machine 'web1' up with 'virtualbox' provider...
    [web1] Box 'leap-wheezy' was not found. Fetching box from specified URL for
    the provider 'virtualbox'. Note that if the URL does not have
    a box for this provider, you should interrupt Vagrant now and add
    the box yourself. Otherwise Vagrant will attempt to download the
    full box prior to discovering this error.
    Downloading or copying the box...
    Progress: 3% (Rate: 560k/s, Estimated time remaining: 0:13:36)
    ...
    Bringing machine 'web1' up with 'virtualbox' provider...
    [web1] Importing base box 'leap-wheezy'...
    0%...10%...20%...30%...40%...50%...60%...70%...80%...90%...100%

Now the virtual machine 'web1' is running. You can add another local node using the same process. For example, the webapp node needs a databasse to run, so let's add a "couchdb" node:

    $ leap node add --local db1 services:couchdb
    $ leap local start
     = updated test/Vagrantfile
    Bringing machine 'db1' up with 'virtualbox' provider...
    [db1] Importing base box 'leap-wheezy'...
    [db1] Matching MAC address for NAT networking...
    [db1] Setting the name of the VM...
    [db1] Clearing any previously set forwarded ports...
    [db1] Fixed port collision for 22 => 2222. Now on port 2202.
    [db1] Creating shared folders metadata...
    [db1] Clearing any previously set network interfaces...
    [db1] Preparing network interfaces based on configuration...
    [db1] Forwarding ports...
    [db1] -- 22 => 2202 (adapter 1)
    [db1] Running any VM customizations...
    [db1] Booting VM...
    [db1] Waiting for VM to boot. This can take a few minutes.
    [db1] VM booted and ready for use!
    [db1] Configuring and enabling network interfaces...
    [db1] Mounting shared folders...
    [db1] -- /vagrant

You now can follow the normal LEAP process and initialize it and then deploy your recipes to it:

    $ leap node init web1
    $ leap deploy web1
    $ leap node init db1
    $ leap deploy db1


Useful local development commands
=================================

There are many useful things you can do with a virtualized development environment. 

Listing what machines are running
---------------------------------

Now you have the two virtual machines "web1" and "db1" running, you can see the running machines as follows:

    $ leap local status
    Current machine states:

    db1                      running (virtualbox)
    web1                     running (virtualbox)

    This environment represents multiple VMs. The VMs are all listed
    above with their current state. For more information about a specific
    VM, run `vagrant status NAME`.

Stopping machines
-----------------

It is not recommended that you leave your virtual machines running when you are not using them. They consume memory and other resources! To stop your machines, simply do the following:

    $ leap local stop web1 db1

Connecting to machines
----------------------

You can connect to your local nodes just like you do with normal LEAP nodes, by running 'leap ssh node'. 

However, if you cannot connect to your local node, because the networking is not setup properly, or you have deployed a firewall that locks you out, you may need to access the graphical console.

In order to do that, you will need to configure Vagrant to launch a graphical console and then you can login as root there to diagnose the networking problem. To do this, add the following to you
$HOME/.leaprc:

    @custom_vagrant_vm_line = 'config.vm.boot_mode = :gui'

and then start, or restart, your local Vagrant node. You should get a VirtualBox graphical interface presented to you showing you the bootup and eventually the login.

Snapshotting machines
---------------------

A very useful feature of local Vagrant development nodes is the ability to snapshot the current state and then revert to that when you need. 

For example, perhaps the base image is a little bit out of date and you want to get the packages updated to the latest before continuing. You can do that simply by starting the node, connecting to it and updating the packages and then snapshotting the node:

    $ leap local start web1
    $ leap ssh web1
    web1# apt-get -u dist-upgrade
    web1# exit
    $ leap local save web1

Now you can deploy to web1 and if you decide you want to revert to the state before deployment, you simply have to reset the node to your previous save:

    $ leap local reset web1

More information
----------------

See `leap help local` for a complete list of local-only commands and how they can be used.


Limitations
===========

Please consult the known issues for vagrant, see the [Known Issues](known-issues), section *Special Environments*


Troubleshooting Vagrant
=======================

To troubleshoot vagrant issues, try going through these steps:

* Try plain vagrant using the [Getting started guide](http://docs.vagrantup.com/v2/getting-started/index.html).
* If that fails, make sure that you can run virtual machines (VMs) in plain virtualbox (Virtualbox GUI or VBoxHeadless). 
  We don't suggest a sepecial howto for that, [this one](http://www.thegeekstuff.com/2012/02/virtualbox-install-create-vm/) seems pretty decent, or you follow the [Oracale Virtualbox User Manual](http://www.virtualbox.org/manual/UserManual.html). There's also specific documentation for [Debian](https://wiki.debian.org/VirtualBox) and for [Ubuntu](https://help.ubuntu.com/community/VirtualBox). If you succeeded, try again if you now can start vagrant nodes using plain vagrant (see first step).
* If plain vagrant works for you, you're very close to using vagrant with leap ! If you encounter any problems now, please [contact us](https://leap.se/en/about-us/contact) or use our [issue tracker](https://leap.se/code)

Known working combinations
--------------------------

Please consider that using other combinations might work for you as well, these are just the combinations we tried and worked for us:


Debian Wheezy
-------------

* `virtualbox-4.2 4.2.16-86992~Debian~wheezy` from Oracle and `vagrant 1.2.2` from vagrantup.com


Ubuntu Raring 13.04
-------------------

* `virtualbox 4.2.10-dfsg-0ubuntu2.1` from Ubuntu raring and `vagrant 1.2.2` from vagrantup.com


Using Vagrant with libvirt/kvm
==============================

Vagrant can be used with different providers/backends, one of them is [vagrant-libvirt](https://github.com/pradels/vagrant-libvirt). Here are the steps how to use it. Be sure to use a recent vagrant version (>= 1.3).

Install vagrant-libvirt plugin and add box
------------------------------------------
    sudo apt-get install libvirt-bin libvirt-dev
    vagrant plugin install vagrant-libvirt
    vagrant plugin install sahara 
    vagrant box add leap-wheezy https://downloads.leap.se/leap-debian-libvirt.box


Debugging
---------

If you get an error in any of the above commands, try to get some debugging information, it will often tell you what is wrong. In order to get debugging logs, you simply need to re-run the command that produced the error but prepend the command with VAGRANT_LOG=info, for example:
    VAGRANT_LOG=info vagrant box add leap-wheezy https://downloads.leap.se/leap-debian-libvirt.box

Start it
--------

Use this example Vagrantfile:

    Vagrant.configure("2") do |config|
      config.vm.define :testvm do |testvm|
        testvm.vm.box = "leap-wheezy"
        testvm.vm.network :private_network, :ip => '10.6.6.201'
      end

      config.vm.provider :libvirt do |libvirt|
        libvirt.connect_via_ssh = false
      end
    end

Then:

    vagrant up --provider=libvirt

If everything works, you should export libvirt as the VAGRANT_DEFAULT_PROVIDER:

    export VAGRANT_DEFAULT_PROVIDER="libvirt" 

Now you should be able to use the `leap local` commands.

Known Issues
------------

* 'Call to virConnectOpen failed: internal error: Unable to locate libvirtd daemon in /usr/sbin (to override, set $LIBVIRTD_PATH to the name of the libvirtd binary)' - you don't have the libvirtd daemon running or installed, be sure you installed the 'libvirt-bin' package and it is running
* 'Call to virConnectOpen failed: Failed to connect socket to '/var/run/libvirt/libvirt-sock': Permission denied' - you need to be in the libvirt group to access the socket, do 'sudo adduser <user> libvirt' and then re-login to your session
* see the [vagrant-libvirt issue list on github](https://github.com/pradels/vagrant-libvirt/issues)
* be sure to use vagrant-libvirt >= 0.0.11 and sahara >= 0.0.16 (which are the latest stable gems you would get with `vagrant plugin install [vagrant-libvirt|sahara]`) for proper libvirt support
