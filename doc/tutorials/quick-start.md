@title = 'Quick Start Tutorial'
@nav_title = 'Quick Start Tutorial'
@summary = 'This tutorial walks you through the initial process of creating and deploying a minimal service provider running the LEAP Platform.'

Introduction
====================================

### Our goal

We are going to create a minimal LEAP provider, but one that does not offer any actual services. Check out the other tutorials for adding VPN or email services.

Our goal is something like this:

    $ leap list
            NODES   SERVICES          TAGS
       wildebeest   couchdb, webapp

NOTE: You won't be able to run that `leap list` command yet, not until we actually create the node configurations.

### Requirements

1. A workstation: This is your local machine that you will run commands on.
1. A server: This is the machine that you will deploy to. The server can be either:
   1. A local Vagrant virtual machine: a Vagrant machine can only be useful for testing.
   1. A real or paravirtualized server: The server must have Debian Jessie installed, and you must be able to SSH into the machine as root. Paravirtualization includes KVM, Xen, OpenStack, Amazon, but not VirtualBox or OpenVZ.

Other things to keep in mind:

* The ability to create/modify DNS entries for your domain is preferable, but not needed. If you don't have access to DNS, you can workaround this by modifying your local resolver, i.e. editing `/etc/hosts`.
* You need to be aware that this process will make changes to your servers, so please be sure that these machines are a basic install with nothing configured or running for other purposes.
* Your servers will need to be connected to the internet, and not behind a restrictive firewall.

Prepare your workstation
========================

In order to be able to manage your servers, you need to install the `leap` command on your workstation:

### Install pre-requisites

Install core prerequisites on your workstation.

*Debian & Ubuntu*

    workstation$ sudo apt-get install git ruby ruby-dev rsync openssh-client openssl rake make bzip2

*Mac OS*

    workstation$ brew install ruby-install
    workstation$ ruby-install ruby

### Install the LEAP command-line utility

Install the `leap` command from rubygems.org:

    workstation$ gem install leap_cli --install-dir ~/leap
    workstation$ export PATH=$PATH:~/leap/bin

Alternately, you can install `leap` system wide:

    workstation$ sudo gem install leap_cli

To confirm that you installed `leap` correctly, try running `leap help`.

Create a provider instance
=============================================

A provider instance is a directory tree, residing on your workstation, that contains everything you need to manage an infrastructure for a service provider.

In this case, we create one for example.org and call the instance directory 'example'.

    workstation$ leap new ~/example

The `leap new` command will ask you for several required values:

* domain: The primary domain name of your service provider. In this tutorial, we will be using "example.org".
* name: The name of your service provider (we use "Example").
* contact emails: A comma separated list of email addresses that should be used for important service provider contacts (for things like postmaster aliases, Tor contact emails, etc).
* platform: The directory where you have a copy of the `leap_platform` git repository checked out. If the platform directory does not yet exist, the `leap_platform` will be downloaded and placed in that directory.

You could also have passed these configuration options on the command-line, like so:

    workstation$ leap new --contacts your@email.here --domain example.org --name Example --platform=~/leap/leap_platform .

You should now have the following files:

    workstation$ tree example
    example
    ├── common.json
    ├── Leapfile
    ├── nodes/
    ├── provider.json
    ├── services/
    └── tags/

Now add yourself as a privileged sysadmin who will have access to deploy to servers:

    workstation$ cd example
    workstation$ leap add-user louise --self

Replace "louise" with whatever you want your sysadmin username to be.

NOTE: Make sure you change directories so that the `leap` command is run from within the provider instance directory. Most `leap` commands only work when run from a provider instance.

Now create the necessary keys and certificates:

    workstation$ leap cert ca
    workstation$ leap cert csr

What do these commands do? The first command will create two Certificate Authorities, one that clients will use to authenticate with the servers and one for backend servers to authenticate with each other. The second command creates a Certificate Signing Request suitable for submission to a commercial CA. It also creates two "dummy" files for you to use temporarily:

* `files/cert/example.org.crt` -- This is a "dummy" certificate for your domain that can be used temporarily for testing. Once you get a real certificate from a CA, you should replace this file.
* `files/cert/commercial_ca.crt` -- This is "dummy" CA cert the corresponds to the dummy domain certificate. Once you replace the domain certificate, also replace this file with the CA cert from the real Certificate Authority.

If you plan to run a real service provider, see important information on [[managing keys and certificates => keys-and-certificates]].

Add a node to the provider
==================================================

A "node" is a server that is part of your infrastructure. Every node can have one or more services associated with it. We will now add a single node with two services, "webapp" and "couchdb".

You have two choices for node type: a real node or a local node.

* Real Node: A real node is any physical or paravirtualized server, including KVM, Xen, OpenStack Compute, Amazon EC2, but not VirtualBox or OpenVZ (VirtualBox and OpenVZ use a more limited form of virtualization). The server must be running Debian Jessie.
* Local Node: A local node is a virtual machine created by Vagrant, useful for local testing on your workstation.

Getting Vagrant working can be a pain and is [[covered in other tutorials => vagrant]]. If you have a real server available, we suggest you try this tutorial with a real node first.

### Option A: Add a real node

Note: Installing LEAP Platform on this server will potentially destroy anything you have previously installed on this machine.

Create a node, with the services "webapp" and "couchdb":

    workstation$ leap node add wildebeest ip_address:x.x.x.w services:webapp,couchdb

NOTE: replace x.x.x.x with the actual IP address of this server.

### Option B: Add a local node

Create a node, with the services "webapp" and "couchdb", and then start the local virtual machine:

    workstation$ leap node add --local wildebeest services:webapp,couchdb
    workstation$ leap local start wildebeest

It will take a while to download the Virtualbox base box and create the virtual machine.

Deploy your provider
=========================================

### Initialize the node

Node initialization only needs to be done once, but there is no harm in doing it multiple times:

    workstation$ leap node init wildebeest

This will initialize the node `wildebeest`.

For non-local nodes, when `leap node init` is run, you will be prompted to verify the fingerprint of the SSH host key and to provide the root password of the server(s). You should only need to do this once.

### Deploy to the node

The next step is to deploy the LEAP platform to your node. [Deployment can take a while to run](https://xkcd.com/303/), especially on the first run, as it needs to update the packages on the new machine.

    workstation$ leap deploy wildebeest

Watch the output for any errors (in red), if everything worked fine, you should now have your first running node. If you do have errors, try doing the deploy again.

### Setup DNS

The next step is to configure the DNS for your provider. For testing purposes, you can just modify your `/etc/hosts` file. Please don't forget about these entries, they will override DNS queries if you setup your DNS later. For a list of what entries to add to `/etc/hosts`, run this command:

    workstation$ leap compile hosts

Alternately, if you have access to modify the DNS zone entries for your domain:

    workstation$ leap compile zone

NOTE: The resulting zone file is incomplete because it is missing a serial number. Use the output of `leap compile zone` as a guide, but do not just copy and paste the output. Also, the `compile zone` output will always exclude mention of local nodes.

The DNS method will not work for local nodes created with Vagrant.

Test that things worked correctly
=================================

To run troubleshooting tests:

    workstation$ leap test

Alternately, you can run these same tests from the server itself:

    workstation$ leap ssh wildebeest
    wildebeest# run_tests

Create an administrator
===============================

Assuming that you set up your DNS or `/etc/hosts` file, you should be able to load `https://example.org` in your web browser (where example.org is whatever domain name you actually used).

Your browser will complain about an untrusted cert, but for now just bypass this. From there, you should be able to register a new user and login.

Once you have created a user, you can now make this user an administrator. For example, if you created a user `kangaroo`, you would create the file `services/webapp.json` with the following content:

    {
        "webapp": {
            "admins": ["kangaroo"]
        }
    }

Save that file and run `leap deploy` again. When you next log on to the web application, the user kangaroo will now be an admin.

If you want to restrict who can register a new user, see [[webapp]] for configuration options.

What is next?
======================

Add an end-user service
-------------------------------

You should now have a minimal service provider with a single node. This service provider is pointless at the moment, because it does not include any end-user services like VPN or email. To add one of these services, continue with one of the following tutorials:

* [[single-node-email]]
* [[single-node-vpn]]

Learn more
---------------

We have only just scratched the surface of the possible ways to configure and deploy your service provider. Your next step should be:

* Read [[getting-started]] for more details on using the LEAP platform.
* See [[commands]] for a list of possible commands.
