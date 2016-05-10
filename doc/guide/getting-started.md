@title = 'Getting Started'
@summary = 'An overview of the LEAP Platform'
@toc = true


Sensitive files
----------------------------------------------

Some files in your provider directory are very sensitive. Leaking these files will compromise your provider.

Super sensitive and irreplaceable:

* `files/ca/*.key` -- the private keys for the client and server CAs.
* `files/cert/*.key` -- the private key(s) for the commercial certificate for your domain(s).

Sensitive, but can be erased and regenerated automatically:

* `secrets.json` -- various random secrets, such as passwords for databases.
* `files/nodes/*/*.key` -- the private key for each node.
* `hiera/*.yaml` -- hiera file contains a copy of the private key of the node.

Also, each sysadmin has one or more public ssh keys in `users/*/*_ssh.pub`. Typically, you will want to keep these public keys secure as well.

See [[keys-and-certificates]] for more information.

Useful commands
-------------------------------------------

Here are a few useful `leap` commands:

* `leap help [COMMAND]` -- get help on COMMAND.
* `leap history [FILTER]` -- show the recent deployment history for the selected nodes.
* `leap ssh web1` -- SSH into node web1 (requires `leap node init web1` first).
* `leap list [FILTER]` -- list the selected nodes.
  * `leap list production` -- list only those nodes with the tag 'production'
  * `leap list --print ip_address` -- list a particular attribute of all nodes.

See the full [[commands]] for more information.

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

See the full [[commands]] for more information.

Tracking the provider directory in git
------------------------------------------

You should commit your provider changes to your favorite VCS whenever things change. This way you can share your configurations with other admins, all they have to do is to pull the changes to stay up to date. Every time you make a change to your provider, such as adding nodes, services, generating certificates, etc. you should add those to your VCS, commit them and push them to where your repository is hosted.

Note that your provider directory contains secrets, such as private key material and passwords. You do not want to have those passwords readable by the world, so make sure that wherever you are hosting your repository, it is not public for the world to read.

If you have a post-commit hook that emails the changes to contributors, you may want to exclude diffs for files that might have sensitive secrets. For example, create a `.gitattributes` file with:

    # No diff, no email for key files
    *.key -diff
    *.pem -diff

    # Discard diff for secrets.json
    secrets.json -diff

    # No diff for hiera files, they contain passwords
    hiera/* -diff


Editing JSON configuration files
--------------------------------------

All the settings that compose your provider are stored in JSON files.

At a minimum, you will need at least two configuration files:

* `provider.json` -- general settings for you provider.
* `nodes/NAME.json` -- configuration file for node called "NAME".

There are a few required properties in provider.json:

    {
      "domain": "example.org",
      "name": "Example",
      "contacts": {
        "default": "email1@example.org"
      }
    }

See [[provider-configuration]] for more details.

For node configuration files, there are two required properties:

    {
      "ip_address": "1.1.1.1",
      "services": ["openvpn"]
    }

See [[services]] for details on what servers are available, and see [[config]] details on how configuration files work.

How does it work under the hood?
--------------------------------------------

You don't need to know any of the details of what happens "under the hood" in order to use the LEAP platform. However, if you are curious as to what is going on, here is a quick primer.

First, some background terminology:

* **puppet**: Puppet is a system for automating deployment and management of servers (called nodes).
* **hiera files**: In puppet, you can use something called a 'hiera file' to seed a node with a few configuration values. In LEAP, we go all out and put *every* configuration value needed for a node in the hiera file, and automatically compile a custom hiera file for each node.

When you run `leap deploy`, a bunch of things happen, in this order:

1. **Compile hiera files**: The hiera configuration file for each node is compiled in YAML format and saved in the directory `hiera`. The source material for this hiera file consists of all the JSON configuration files imported or inherited by the node's JSON config file.
* **Copy required files to node**: All the files needed for puppet to run are rsync'ed to each node. This includes the entire leap_platform directory, as well as the node's hiera file and other files needed by puppet to set up the node (keys, binary files, etc).
* **Puppet is run**: Once the node is ready, leap connects to the node via ssh and runs `puppet apply`. Puppet is applied locally on the node, without a daemon or puppetmaster.

You can run `leap -v2 deploy` to see exactly what commands are being executed.

This mode of operation is fundamentally different from how puppet is normally used:

* There is no puppetmaster that all the servers take orders from, and there is no puppetd running in the background.
* Servers cannot dynamically query the puppetmaster for information about the other servers.
* There is a static representation for the state of every server that can be committed to git.

There are advantages and disadvantages to the model that LEAP uses. We have found it very useful for our goal of having a common LEAP platform that many different providers can all use while still allowing providers to configure their unique infrastructure.

We also find it very beneficial to be able to track the state of your infrastructure in git.

Traditional system configuration automation systems, like [Puppet](https://puppetlabs.com/puppet/puppet-open-source/) or [Chef](http://www.opscode.com/chef/), deploy changes to servers using a pull method. Each server pulls a manifest from a central master server and uses this to alter the state of the server.

Instead, the `leap` tool uses a masterless push method: The sysadmin runs `leap deploy` from the provider instance directory on their desktop machine to push the changes out to every server (or a subset of servers). LEAP still uses Puppet, but there is no central master server that each node must pull from.

One other significant difference between LEAP and typical system automation is how interactions among servers are handled. Rather than store a central database of information about each server that can be queried when a recipe is applied, the `leap` command compiles static representation of all the information a particular server will need in order to apply the recipes. In compiling this static representation, `leap` can use arbitrary programming logic to query and manipulate information about other servers.

These two approaches, masterless push and pre-compiled static configuration, allow the sysadmin to manage a set of LEAP servers using traditional software development techniques of branching and merging, to more easily create local testing environments using virtual servers, and to deploy without the added complexity and failure potential of a master server.
