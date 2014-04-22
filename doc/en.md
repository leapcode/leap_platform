@title = 'LEAP Platform for Service Providers'
@nav_title = 'Provider Platform'
@summary = 'Software platform to automate the process of running a communication service provider.'
@toc = true

The *LEAP Platform* is set of complementary packages and server recipes to automate the maintenance of LEAP services in a hardened Debian environment. Its goal is to make it as painless as possible for sysadmins to deploy and maintain a service provider's infrastructure for secure communication.

The LEAP Platform consists of three parts, detailed below:

1. The platform recipes.
2. The provider instance.
3. The `leap` command line tool.

The platform recipes
--------------------

The LEAP platform recipes define an abstract service provider. It is a set of [Puppet](https://puppetlabs.com/puppet/puppet-open-source/) modules designed to work together to provide to sysadmins everything they need to manage a service provider infrastructure that provides secure communication services.

LEAP maintains a repository of platform recipes, which typically do not need to be modified, although it can be forked and merged as desired. Most service providers using the LEAP platform can use the same set of platform recipes.

As these recipes consist in abstract definitions, in order to configure settings for a particular service provider a system administrator has to create a provider instance (see below).

LEAP's platform recipes are distributed as a git repository: `https://leap.se/git/leap_platform`

The provider instance
---------------------

A provider instance is a directory tree (typically tracked in git) containing all the configurations for a service provider's infrastructure. A provider instance primarily consists of:

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

The `leap` [command line tool](commands) is used by sysadmins to manage everything about a service provider's infrastructure. Except when creating an new provider instance, `leap` is run from within the directory tree of a provider instance.

The `leap` command line has many capabilities, including:

* Create, initialize, and deploy nodes.
* Manage keys and certificates.
* Query information about the node configurations.

Traditional system configuration automation systems, like [Puppet](https://puppetlabs.com/puppet/puppet-open-source/) or [Chef](http://www.opscode.com/chef/), deploy changes to servers using a pull method. Each server pulls a manifest from a central master server and uses this to alter the state of the server.

Instead, the `leap` tool uses a masterless push method: The sysadmin runs `leap deploy` from the provider instance directory on their desktop machine to push the changes out to every server (or a subset of servers). LEAP still uses Puppet, but there is no central master server that each node must pull from.

One other significant difference between LEAP and typical system automation is how interactions among servers are handled. Rather than store a central database of information about each server that can be queried when a recipe is applied, the `leap` command compiles static representation of all the information a particular server will need in order to apply the recipes. In compiling this static representation, `leap` can use arbitrary programming logic to query and manipulate information about other servers.

These two approaches, masterless push and pre-compiled static configuration, allow the sysadmin to manage a set of LEAP servers using traditional software development techniques of branching and merging, to more easily create local testing environments using virtual servers, and to deploy without the added complexity and failure potential of a master server.

The `leap` command line tool is distributed as a git repository: `https://leap.se/git/leap_cli`. It can be installed with `sudo gem install leap_cli`.

Getting started
----------------------------------

We recommend reading the platform documentation in the following order:

1. [Quick start tutorial](platform/quick-start).
2. [Platform Guide](platform/guide).
3. [Configuration format](platform/config).
4. The `leap` [command reference](platform/commands).
