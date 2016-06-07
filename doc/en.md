@title = 'LEAP Platform for Service Providers'
@summary = "The LEAP Platform is set of complementary packages and server recipes to automate the maintenance of LEAP services in a hardened Debian environment."
@nav_title = 'Provider Platform'
@this.toc = false

Its goal is to make it as painless as possible for sysadmins to deploy and maintain a service provider's infrastructure for secure communication.

**REQUIREMENTS** -- Before you begin, make sure you meet these requirements:

* *Debian Servers*: Servers that you deploy to must be running **Debian Jessie**, and no other distribution or version.
* *Real or Paravirtualized Servers*: Servers must be real machines or paravirtualized VMs (e.g. KVM, Xen, OpenStack, AWS, Google Compute). OS level virtualization is not supported (e.g. OpenVZ, Linux-VServer, etc), nor are system emulators (VirtualBox, QEMU, etc).
* *Your Workstation*: You must have a Linux or Mac computer to deploy from (this can be a headless machine with no GUI). Windows is not supported (Cygwin would probably work, but is untested).
* *Your Own Domain*: You must own a domain name. Before your provider can be put into production, you will need to make modifications to the DNS for the provider's domain.

The LEAP Platform consists of three parts, detailed below:

1. [The platform recipes.](#the-platform-recipes)
2. [The provider instance.](#the-provider-instance)
3. [The `leap` command line tool.](#the-leap-command-line-tool)

The platform recipes
--------------------

The LEAP platform recipes define an abstract service provider. It is a set of [Puppet](https://puppetlabs.com/puppet/puppet-open-source/) modules designed to work together to provide to sysadmins everything they need to manage a service provider infrastructure that provides secure communication services.

LEAP maintains a repository of platform recipes, which typically do not need to be modified, although it can be forked and merged as desired. Most service providers using the LEAP platform can use the same set of platform recipes.

As these recipes consist in abstract definitions, in order to configure settings for a particular service provider a system administrator has to create a provider instance (see below).

LEAP's platform recipes are distributed as a git repository: `https://leap.se/git/leap_platform`

The provider instance
---------------------

A provider instance is a directory tree (typically tracked in git) containing all the configurations for a service provider's infrastructure. A provider instance **lives on your workstation**, not on the server.

A provider instance primarily consists of:

* A pointer to the platform recipes.
* A global configuration file for the provider.
* A configuration file for each server (node) in the provider's infrastructure.
* Additional files, such as certificates and keys.

A minimal provider instance directory looks like this:

    └── bitmask                 # provider instance directory.
        ├── Leapfile            # settings for the `leap` command line tool.
        ├── provider.json       # global settings of the provider.
        ├── common.json         # settings common to all nodes.
        ├── nodes/              # a directory for node configurations.
        ├── files/              # keys, certificates, and other files.
        └── users/              # public key information for privileged sysadmins.

A provider instance directory contains everything needed to manage all the servers that compose a provider's infrastructure. Because of this, any versioning tool and development work-flow can be used to manage your provider instance.

The `leap` command line tool
----------------------------

The `leap` [command line tool](commands) is used by sysadmins to manage everything about a service provider's infrastructure.

Keep these rules in mind:

* `leap` is run on your workstation: The `leap` command is always run locally on your workstation, never on a server you are deploying to.
* `leap` is run from within a provider instance: The `leap` command requires that the current working directory is a valid provider instance, except when running `leap new` to create a new provider instance.

The `leap` command line has many capabilities, including:

* Create, initialize, and deploy nodes.
* Manage keys and certificates.
* Query information about the node configurations.

Everything about your provider is managed by editing JSON configuration files and running `leap` commands.

What is next?
----------------------------------

We recommend reading the platform documentation in the following order:

1. [[quick-start]]
2. [[getting-started]]
3. [[platform/guide]]

