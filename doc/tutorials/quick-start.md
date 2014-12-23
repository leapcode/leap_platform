@title = 'LEAP Platform Quick Start'
@nav_title = 'Quick Start'
@summary = 'Three node OpenVPN provider.'

Quick Start
===========

This tutorial walks you through the initial process of creating and deploying a minimal service provider running the [LEAP platform](platform). This Quick Start guide will guide you through building a three node OpenVPN provider.

Our goal
------------------

We are going to create a minimal LEAP provider offering OpenVPN service. This basic setup can be expanded by adding more OpenVPN nodes to increase capacity, or more webapp and couchdb nodes to increase availability (performance wise, a single couchdb and a single webapp are more than enough for most usage, since they are only lightly used, but you might want redundancy). Please note: currently it is not possible to safely add additional couchdb nodes at a later point. They should all be added in the beginning, so please consider carefully if you would like more before proceeding.

Our goal is something like this:

    $ leap list
         NODES   SERVICES    TAGS
       cheetah   couchdb     production
    wildebeest   webapp      production
       ostrich   openvpn     production

NOTE: You won't be able to run that `leap list` command yet, not until we actually create the node configurations.

Requirements
------------

In order to complete this Quick Start, you will need a few things:

* You will need three real or paravirtualized virtual machines (KVM, Xen, Openstack, Amazon, but not Vagrant - sorry) that have a basic Debian Stable installed. If you allocate 20G of disk space to each node for the system, after this process is completed, you will have used less than 10% of that disk space. If you allocate 2 CPUs and 8G of memory to each node, that should be more than enough to begin with.
* You should be able to SSH into them remotely, and know their root password, IP addresses and their SSH host keys
* You will need four different IPs. Each node gets a primary IP, and the OpenVPN gateway additionally needs a gateway IP.
* The ability to create/modify DNS entries for your domain is preferable, but not needed. If you don't have access to DNS, you can workaround this by modifying your local resolver, i.e. editing `/etc/hosts`.
* You need to be aware that this process will make changes to your systems, so please be sure that these machines are a basic install with nothing configured or running for other purposes
* Your machines will need to be connected to the internet, and not behind a restrictive firewall.
* You should work locally on your laptop/workstation (one that you trust and that is ideally full-disk encrypted) while going through this guide. This is important because the provider configurations you are creating contain sensitive data that should not reside on a remote machine. The `leap` command will login to your servers and configure the services.
* You should do everything described below as an unprivileged user, and only run those commands as root that are noted with *sudo* in front of them. Other than those commands, there is no need for privileged access to your machine, and in fact things may not work correctly.

All the commands in this tutorial are run on your sysadmin machine. In order to complete the tutorial, the sysadmin will do the following:

* Install pre-requisites
* Install the LEAP command-line utility
* Check out the LEAP platform
* Create a provider and its certificates
* Setup the provider's nodes and the services that will reside on those nodes
* Initialize the nodes
* Deploy the LEAP platform to the nodes
* Test that things worked correctly
* Some additional commands

We will walk you through each of these steps.


Prepare your environment
========================

There are a few things you need to setup before you can get going. Just some packages, the LEAP cli and the platform.

Install pre-requisites
--------------------------------

*Debian & Ubuntu*

Install core prerequisites:

    $ sudo apt-get install git ruby ruby-dev rsync openssh-client openssl rake make bzip2

<!--
*Mac OS*

1. Install rubygems from https://rubygems.org/pages/download (unless the `gem` command is already installed).
-->

NOTE: leap_cli requires ruby 1.9 or later.


Install the LEAP command-line utility
-------------------------------------------------

Install the `leap` command from rubygems.org:

    $ sudo gem install leap_cli

Alternately, you can install `leap` from source:

    $ git clone https://leap.se/git/leap_cli
    $ cd leap_cli
    $ rake build
    $ sudo rake install

You can also install from source as an unprivileged user, if you want. For example, instead of `sudo rake install` you can do something like this:

    $ rake install
    # watch out for the directory leap is installed to, then i.e.
    $ sudo ln -s ~/.gem/ruby/1.9.1/bin/leap /usr/local/bin/leap

With either `rake install` or `sudo rake install`, you can use now /usr/local/bin/leap, which in most cases will be in your $PATH.

If you have successfully installed the `leap` command, then you should be able to do the following:

    $ leap --help

This will list the command-line help options. If you receive an error when doing this, please read through the README.md in the `leap_cli` source to try and resolve any problems before going forwards.

Check out the platform
--------------------------

The LEAP Platform is a series of puppet recipes and modules that will be used to configure your provider. You will need a local copy of the platform that will be used to setup your nodes and manage your services. To begin with, you will not need to modify the LEAP Platform.

First we'll create a directory for LEAP things, and then we'll check out the platform code and initalize the modules:

    $ mkdir ~/leap
    $ cd ~/leap
    $ git clone https://leap.se/git/leap_platform.git
    $ cd leap_platform
    $ git submodule sync; git submodule update --init


Provider Setup
==============

A provider instance is a directory tree, usually stored in git, that contains everything you need to manage an infrastructure for a service provider. In this case, we create one for example.org and call the instance directory 'example'.

    $ mkdir -p ~/leap/example

Bootstrap the provider
-----------------------

Now, we will initialize this directory to make it a provider instance. Your provider instance will need to know where it can find the local copy of the git repository leap_platform, which we setup in the previous step.

    $ cd ~/leap/example
    $ leap new .

NOTES:
 . make sure you include that trailing dot!

The `leap new` command will ask you for several required values:

* domain: The primary domain name of your service provider. In this tutorial, we will be using "example.org".
* name: The name of your service provider (we use "Example").
* contact emails: A comma separated list of email addresses that should be used for important service provider contacts (for things like postmaster aliases, Tor contact emails, etc).
* platform: The directory where you have a copy of the `leap_platform` git repository checked out.

You could also have passed these configuration options on the command-line, like so:

    $ leap new --contacts your@email.here --domain leap.example.org --name Example --platform=~/leap/leap_platform .

You may want to poke around and see what is in the files we just created. For example:

    $ cat provider.json

Optionally, commit your provider directory using the version control software you fancy. For example:

    $ git init
    $ git add .
    $ git commit -m "initial provider commit"

Now add yourself as a privileged sysadmin who will have access to deploy to servers:

    $ leap add-user --self

NOTE: in most cases, `leap` must be run from within a provider instance directory tree (e.g. ~/leap/example).

Create provider certificates
----------------------------

Create two certificate authorities, one for server certs and one for client
certs (note: you only need to run this one command to get both):

    $ leap cert ca

Create a temporary cert for your main domain (you should replace with a real commercial cert at some point)

    $ leap cert csr

To see details about the keys and certs that the prior two commands created, you can use `leap inspect` like so:

    $ leap inspect files/ca/ca.crt

Create the Diffie-Hellman parameters file, needed for forward secret OpenVPN ciphers:

    $ leap cert dh

NOTE: the files `files/ca/*.key` are extremely sensitive and must be carefully protected. The other key files are much less sensitive and can simply be regenerated if needed.


Edit provider.json configuration
--------------------------------------

There are a few required settings in provider.json. At a minimum, you must have:

    {
      "domain": "example.org",
      "name": "Example",
      "contacts": {
        "default": "email1@example.org"
      }
    }

For a full list of possible settings, you can use `leap inspect` to see how provider.json is evaluated after including the inherited defaults:

    $ leap inspect provider.json


Setup the provider's nodes and services
---------------------------------------

A "node" is a server that is part of your infrastructure. Every node can have one or more services associated with it. Some nodes are "local" and used only for testing, see [Development](development) for more information.

Create a node, with the service "webapp":

    $ leap node add wildebeest ip_address:x.x.x.w services:webapp tags:production

NOTE: replace x.x.x.w with the actual IP address of this node

This created a node configuration file in `nodes/wildebeest.json`, but it did not do anything else. It also added the 'tag' called 'production' to this node. Tags allow us to conveniently group nodes together. When creating nodes, you should give them the tag 'production' if the node is to be used in your production infrastructure.

The web application and the VPN nodes require a database, so lets create the database server node:

    $ leap node add cheetah ip_address:x.x.x.x services:couchdb tags:production

NOTE: replace x.x.x.x with the actual IP address of this node

Now we need the OpenVPN gateway, so lets create that node:

    $ leap node add ostrich ip_address:x.x.x.y openvpn.gateway_address:x.x.x.z services:openvpn tags:production

NOTE: replace x.x.x.y with the IP address of the machine, and x.x.x.z with the second IP. openvpn gateways must be assigned two IP addresses, one for the host itself and one for the openvpn gateway. We do this to prevent incoming and outgoing VPN traffic on the same IP. Without this, the client might send some traffic to other VPN users in the clear, bypassing the VPN.


Setup DNS
---------

Now that you have the nodes configured, you should create the DNS entries for these nodes.

Set up your DNS with these hostnames:

    $ leap list --print ip_address,domain.full,dns.aliases
       cheetah  x.x.x.w, cheetah.example.org, null
    wildebeest  x.x.x.x, wildebeest.example.org, api.example.org
       ostrich  x.x.x.y, ostrich.example.org, null

Alternately, you can adapt this zone file snippet:

    $ leap compile zone

If you cannot edit your DNS zone file, you can still test your provider by adding entries to your local resolver hosts file (`/etc/hosts` for linux):

    x.x.x.w cheetah.example.org
    x.x.x.x wildebeest.example.org api.example.org example.org
    x.x.x.y ostrich.example.org

Please don't forget about these entries, they will override DNS queries if you setup your DNS later.


Initialize the nodes
--------------------

Node initialization only needs to be done once, but there is no harm in doing it multiple times:

    $ leap node init production

This will initialize all nodes with the tag "production". When `leap node init` is run, you will be prompted to verify the fingerprint of the SSH host key and to provide the root password of the server(s). You should only need to do this once.

If you prefer, you can initalize each node, one at a time:

    $ leap node init wildebeest
    $ leap node init cheetah
    $ leap node init ostrich

Deploy the LEAP platform to the nodes
--------------------

Now you should deploy the platform recipes to the nodes. [Deployment can take a while to run](http://xkcd.com/303/), especially on the first run, as it needs to update the packages on the new machine.

*Important notes:* currently nodes must be deployed in a certain order. The underlying couch database node(s) must be deployed first, and then all other nodes. Also you need to configure and deploy all of the couchdb nodes that you plan to use at this time, as currently you cannot add more of them later later ([See](https://leap.se/es/docs/platform/known-issues#CouchDB.Sync)).

    $ leap deploy cheetah

Watch the output for any errors (in red), if everything worked fine, you should now have your first running node. If you do have errors, try doing the deploy again.

However, to deploy our three-node openvpn setup, we need the database and LEAP web application requires a database to run, so let's deploy to the couchdb and openvpn nodes:

    $ leap deploy wildebeest
    $ leap deploy ostrich


What is going on here?
--------------------------------------------

First, some background terminology:

* **puppet**: Puppet is a system for automating deployment and management of servers (called nodes).
* **hiera files**: In puppet, you can use something called a 'hiera file' to seed a node with a few configuration values. In LEAP, we go all out and put *every* configuration value needed for a node in the hiera file, and automatically compile a custom hiera file for each node.

When you run `leap deploy`, a bunch of things happen, in this order:

1. **Compile hiera files**: The hiera configuration file for each node is compiled in YAML format and saved in the directory `hiera`. The source material for this hiera file consists of all the JSON configuration files imported or inherited by the node's JSON config file.
* **Copy required files to node**: All the files needed for puppet to run are rsync'ed to each node. This includes the entire leap_platform directory, as well as the node's hiera file and other files needed by puppet to set up the node (keys, binary files, etc).
* **Puppet is run**: Once the node is ready, leap connects to the node via ssh and runs `puppet apply`. Puppet is applied locally on the node, without a daemon or puppetmaster.

You can run `leap -v2 deploy` to see exactly what commands are being executed.


Test that things worked correctly
=================================

You should now have three machines with the LEAP platform deployed to them, one for the web application, one for the database and one for the OpenVPN gateway.

To run troubleshooting tests:

    leap test

If you want to confirm for yourself that things are working, you can perform the following manual tests.

### Access the web application

In order to connect to the web application in your browser, you need to point your domain at the IP address of the web application node (named wildebeest in this example).

There are a lot of different ways to do this, but one easy way is to modify your `/etc/hosts` file. First, find the IP address of the webapp node:

    $ leap list webapp --print ip_address

Then modify `/etc/hosts` like so:

    x.x.x.w   leap.example.org

Replacing 'leap.example.org' with whatever you specified as the `domain` in the `leap new` command.

Next, you can connect to the web application either using a web browser or via the API using the LEAP client. To use a browser, connect to https://leap.example.org (replacing that with your domain). Your browser will complain about an untrusted cert, but for now just bypass this. From there, you should be able to register a new user and login.

### Use the VPN

You should be able to simply test that the OpenVPN gateway works properly by doing the following:

    $ leap test init
    $ sudo openvpn test/openvpn/production_unlimited.ovpn

Or, you can use the LEAP client (called "bitmask") to connect to your new provider, create a user and then connect to the VPN.


Additional information
======================

It is useful to know a few additional things.

Useful commands
---------------

Here are a few useful commands you can run on your new local nodes:

* `leap ssh wildebeest` -- SSH into node wildebeest (requires `leap node init wildebeest` first).
* `leap list` -- list all nodes.
* `leap list production` -- list only those nodes with the tag 'production'
* `leap list --print ip_address` -- list a particular attribute of all nodes.
* `leap cert update` -- generate new certificates if needed.

See the full command reference for more information.

Node filters
-------------------------------------------

Many of the `leap` commands take a "node filter". You can use a node filter to target a command at one or more nodes.

A node filter consists of one or more keywords, with an optional "+" before each keyword.

* keywords can be a node name, a service type, or a tag.
* the "+" before the keyword constructs an AND condition
* otherwise, multiple keywords together construct an OR condition

Examples:

* `leap list openvpn` -- list all nodes with service openvpn.
* `leap list openvpn +production` -- only nodes of service type openvpn AND tag production.
* `leap deploy webapp openvpn` -- deploy to all webapp OR openvpn nodes.
* `leap node init ostrich` -- just init the node named ostrich.

Keep track of your provider configurations
------------------------------------------

You should commit your provider changes to your favorite VCS whenever things change. This way you can share your configurations with other admins, all they have to do is to pull the changes to stay up to date. Every time you make a change to your provider, such as adding nodes, services, generating certificates, etc. you should add those to your VCS, commit them and push them to where your repository is hosted.

Note that your provider directory contains secrets! Those secrets include passwords for various services. You do not want to have those passwords readable by the world, so make sure that wherever you are hosting your repository, it is not public for the world to read.

What's next
-----------------------------------

Read the [LEAP platform guide](guide) to learn about planning and securing your infrastructure.

