@title = 'Single node email tutorial'
@nav_title = 'Single node email'
@summary = 'A single node email provider.'

Quick Start - Single node setup
===============================

This tutorial walks you through the initial process of creating and deploying a minimal service provider running the [LEAP platform](platform).
We will guide you through building a single node mail provider.

Our goal
------------------

We are going to create a minimal LEAP provider offering Email service. This basic setup can be expanded by adding more webapp and couchdb nodes to increase availability (performance wise, a single couchdb and a single webapp are more than enough for most usage, since they are only lightly used, but you might want redundancy). Please note: currently it is not possible to safely add additional couchdb nodes at a later point. They should all be added in the beginning, so please consider carefully if you would like more before proceeding.

Our goal is something like this:

    $ leap list
        NODES   SERVICES                       TAGS
        node1   couchdb, mx, soledad, webapp   local

NOTE: You won't be able to run that `leap list` command yet, not until we actually create the node configurations.

Requirements
------------

In order to complete this Quick Start, you will need a few things:

* You will need `one real or paravirtualized virtual machine` (Vagrant, KVM, Xen, Openstack, Amazon, …) that have a basic Debian Stable installed.
* You should be able to `SSH into them` remotely, and know their root password, IP addresses and their SSH host keys
* The ability to `create/modify DNS entries` for your domain is preferable, but not needed. If you don't have access to DNS, you can workaround this by modifying your local resolver, i.e. editing `/etc/hosts`.
* You need to be aware that this process will make changes to your machines, so please be sure that these machines are a basic install with nothing configured or running for other purposes
* Your machines will need to be connected to the internet, and not behind a restrictive firewall.
* You should `work locally on your laptop/workstation` (one that you trust and that is ideally full-disk encrypted) while going through this guide. This is important because the provider configurations you are creating contain sensitive data that should not reside on a remote machine. The leap cli utility will login to your servers and configure the services.
* You should do everything described below as an `unprivileged user`, and only run those commands as root that are noted with *sudo* in front of them. Other than those commands, there is no need for privileged access to your machine, and in fact things may not work correctly.

All the commands in this tutorial are run on your sysadmin machine. In order to complete the tutorial, the sysadmin will do the following:

* Install pre-requisites
* Install the LEAP command-line utility
* Check out the LEAP platform
* Create a provider and its certificates
* Setup the provider's node and the services that will reside on it
* Initialize the node
* Deploy the LEAP platform to the node
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

*Mac OS*

Install rubygems from https://rubygems.org/pages/download (unless the `gem` command is already installed).


NOTE: leap_cli should work with ruby1.8, but has only been tested using ruby1.9.


Install the LEAP command-line utility
-------------------------------------------------

Install the LEAP command-line utility (leap_cli) from rubygems.org:

    $ sudo gem install leap_cli

Alternately, you can install `leap_cli` from source, please refer to https://leap.se/git/leap_cli/README.md.

If you have successfully installed `leap_cli`, then you should be able to do the following:

    $ leap --help

This will list the command-line help options. If you receive an error when doing this, please read through the README.md in the `leap_cli` source to try and resolve any problems before going forwards.


Provider Setup
==============

A provider instance is a directory tree that contains everything you need to manage an infrastructure for a service provider. In this case, we create one for example.org and call the instance directory 'example'.

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
* platform: The directory where you either have a copy of the `leap_platform` git repository already checked out, or where `leap_cli` should download it too. You could just accept the suggested path for this example.
  The LEAP Platform is a series of puppet recipes and modules that will be used to configure your provider. You will need a local copy of the platform that will be used to setup your nodes and manage your services. To begin with, you will not need to modify the LEAP Platform.

These steps should be sufficient for this example. If you want to configure your provider further or like to examine the files, please refer to the [Configure Provider](configure-provider) section.

Add Users who will have administrative access
---------------------------------------------

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


Setup the provider's node and services
--------------------------------------

A "node" is a server that is part of your infrastructure. Every node can have one or more services associated with it. Some nodes are "local" and used only for testing, see [Development](development) for more information.

Create a node, with `all the services needed for Email: "couchdb", "mx", "soledad" and "webapp"`

    $ leap node add node1 ip_address:x.x.x.w services:couchdb,mx,soledad,webapp

NOTE: replace x.x.x.w with the actual IP address of this node

This created a node configuration file in `nodes/node1.json`, but it did not do anything else. It also added the 'tag' called 'production' to this node. Tags allow us to conveniently group nodes together. When creating nodes, you should give them the tag 'production' if the node is to be used in your production infrastructure.

Initialize the nodes
--------------------

Node initialization only needs to be done once, but there is no harm in doing it multiple times:

    $ leap node init node1

This will initialize the node "node1". When `leap node init` is run, you will be prompted to verify the fingerprint of the SSH host key and to provide the root password of the server. You should only need to do this once.


Deploy the LEAP platform to the nodes
--------------------

Now you should deploy the platform recipes to the node. [Deployment can take a while to run](http://xkcd.com/303/), especially on the first run, as it needs to update the packages on the new machine.

    $ leap deploy

Watch the output for any errors (in red), if everything worked fine, you should now have your first running node. If you do have errors, try doing the deploy again.


Setup DNS
---------

Now that you have the node configured, you should create the DNS entrie for this node.

Set up your DNS with these hostnames:

    $ leap list --print ip_address,domain.full,dns.aliases
         node1  x.x.x.w, node1.example.org, example.org, api.example.org, nicknym.example.org

Alternately, you can adapt this zone file snippet:

    $ leap compile zone

If you cannot edit your DNS zone file, you can still test your provider by adding this entry to your local resolver hosts file (`/etc/hosts` for linux):

    x.x.x.w node1.example.org example.org api.example.org nicknym.example.org

Please don't forget about these entries, they will override DNS queries if you setup your DNS later.


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

<!-- See [under the hood](under-the-hood) for more details. -->


Test that things worked correctly
=================================

You should now one machine with the LEAP platform email service deployed to it.


Access the web application
--------------------------------------------

In order to connect to the web application in your browser, you need to point your domain at the IP address of your new node.

Next, you can connect to the web application either using a web browser or via the API using the LEAP client. To use a browser, connect to https://example.org (replacing that with your domain). Your browser will complain about an untrusted cert, but for now just bypass this. From there, you should be able to register a new user and login.

Testing with leap_cli
---------------------

Use the test command to run a set of different tests:

    leap test


Additional information
======================

It is useful to know a few additional things.

Useful commands
---------------

Here are a few useful commands you can run on your new local nodes:

* `leap ssh web1` -- SSH into node web1 (requires `leap node init web1` first).
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
* `leap node init vpn1` -- just init the node named vpn1.

Keep track of your provider configurations
------------------------------------------

You should commit your provider changes to your favorite VCS whenever things change. This way you can share your configurations with other admins, all they have to do is to pull the changes to stay up to date. Every time you make a change to your provider, such as adding nodes, services, generating certificates, etc. you should add those to your VCS, commit them and push them to where your repository is hosted.

Note that your provider directory contains secrets! Those secrets include passwords for various services. You do not want to have those passwords readable by the world, so make sure that wherever you are hosting your repository, it is not public for the world to read.

What's next
-----------------------------------

Read the [LEAP platform guide](guide) to learn about planning and securing your infrastructure.

