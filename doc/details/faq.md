@title = 'Frequently asked questions'
@nav_title = 'FAQ'
@summary = "Frequently Asked Questions"
@toc = true

APT
===============

What do I do when unattended upgrades fail?
--------------------------------------------------

When you receive notification e-mails with a subject of 'unattended-upgrades result for $machinename', that means that some package couldn't be automatically upgraded and needs manual interaction. The reasons vary, so you have to be careful. Most often you can simply login to the affected machine and run `apt-get dist-upgrade`.

Puppet
======

Where do i find the time a server was last deployed ?
-----------------------------------------------------

The puppet state file on the node indicates the last puppetrun:

    ls -la /var/lib/puppet/state/state.yaml

What resources are touched by puppet/leap_platform (services/packages/files etc.) ?
-----------------------------------------------------------------------------------

Log into your server and issue:

    grep -v '!ruby/sym' /var/lib/puppet/state/state.yaml | sed 's/\"//' | sort


How can i customize the leap_platform puppet manifests ?
--------------------------------------------------------

You can create custom puppet modules under `files/puppet`.
The custom puppet entry point is in class 'custom' which can be put into
`files/puppet/modules/custom/manifests/init.pp`. This class gets automatically included
by site_config::default, which is applied to all nodes.

Of cause you can also create a different git branch and change whatever you want, if you are
familiar wit git.

Facter
======

How can i see custom facts distributed by leap_platform on a node ?
-------------------------------------------------------------------

On the server, export the FACTERLIB env. variable to include the path of the custom fact in question:

    export FACTERLIB=/var/lib/puppet/lib/facter:/srv/leap/puppet/modules/stdlib/lib/facter/
    facter


Etc
===

How do i change the domain of my provider ?
-------------------------------------------

* First of all, you need to have access to the nameserver config of your new domain.
* Update domain in provider.json
* remove all ca and cert files: `rm files/cert/* files/ca/*`
* create ca, csr and certs : `leap cert ca; leap cert csr; leap cert dh; leap cert update`
* deploy
