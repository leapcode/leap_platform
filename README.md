Leap Platform
=============================

[![Build Status](https://0xacab.org/leap/platform/badges/develop/build.svg)](https://0xacab.org/leap/platform/commits/develop)

The LEAP Platform is set of complementary packages and server recipes to automate the maintenance of LEAP services in a hardened Debian environment. Its goal is to make it as painless as possible for sysadmins to deploy and maintain a service provider's infrastructure for secure communication. These recipes define an abstract service provider. It is a set of Puppet modules designed to work together to provide to sysadmins everything they need to manage a service provider infrastructure that provides secure communication services.

Getting started
=============================

It is highly recommended that you start by reading the overview of the [LEAP Platform](https://leap.se/docs/platform) and then begin with the [Quick Start tutorial](https://leap.se/en/docs/platform/tutorials/quick-start) to walk through a test environment setup to get familiar with how things work before deploying to live servers.

An offline copy of this documentation is contained in the `doc` subdirectory. For more current updates to the documentation, visit the website.

Requirements
------------------

For testing a virtual deployment simulated on your computer, you will need a fairly recent computer x86_64 with hardware virtualization features (AMD-V or VT-x) and plenty of RAM. If you follow the "Quick Start" documentation we will walk you through using Vagrant to setup a test deployment.

For a live deployment of the platform, the number of servers that is required depends on your needs and which services you want to deploy. At the moment, the LEAP Platform supports servers with a base Debian Wheezy installation.

Troubleshooting
=============================

If you have a problem, we are interested in fixing it!

If you have a problem, be sure to have a look at the [Known Issues](https://leap.se/docs/platform/known-issues) to see if your issue is detailed there.

If not, the best way for us to solve your problem is if you provide to us the complete log of what you did, and the output that was produced. Please don't cut out what appears to be useless information and only include the error that you received, instead copy and paste the complete log so that we can better determine the overall situation. If you can run the same command that produced the error with a raised verbosity level (such as -v2), that provides us with more useful debugging information.

To capture the log, you can copy from the console, or run `leap --log FILE` or edit Leapfile to include `@log = '/tmp/leap.log'`.

Visit https://leap.se/en/docs/get-involved/communication for details on how to contact the developers.

Known issues
============

The following issues are known to exist in 0.5.2 and later:

CouchDB Sync
------------
You can't deploy new couchdb nodes after one or more have been deployed. Make *sure* that you configure and deploy all your couchdb nodes when first creating your provider. The problem is that we dont not have a clean way of adding couch nodes after initial creation of the databases, so any nodes added after result in improperly synchronized data. See Bug [#5601](https://leap.se/code/issues/5601) for more information.

User setup and ssh
------------------

. if you aren't using a single ssh key, but have different ones, you will need to define the following at the top of your ~/.ssh/config:
  HostName <ip address>
  IdentityFile <path to identity file>

  (see: https://leap.se/code/issues/2946 and https://leap.se/code/issues/3002)

. If the ssh host key changes, you need to run node init again (see: https://leap.se/en/docs/platform/guide#Working.with.SSH)

. At the moment, only ECDSA ssh host keys are supported. If you get the following error: `= FAILED ssh-keyscan: no hostkey alg (must be missing an ecdsa public host key)` then you should confirm that you have the following line defined in your server's **/etc/ssh/sshd_config**: `HostKey /etc/ssh/ssh_host_ecdsa_key`. If that file doesn't exist, run `ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N ""` in order to create it. If you made a change to your sshd_config, then you need to run `/etc/init.d/ssh restart` (see: https://leap.se/code/issues/2373)

. To remove an admin's access to your servers, please remove the directory for that user under the `users/` subdirectory in your provider directory and then remove that user's ssh keys from files/ssh/authorized_keys. When finished you *must* run a `leap deploy` to update that information on the servers.

. At the moment, it is only possible to add an admin who will have access to all LEAP servers (see: https://leap.se/code/issues/2280)

. leap add-user --self allows only one key - if you run that command twice with different keys, you will just replace the key with the second key. To add a second key, add it manually to files/ssh/authorized_keys (see: https://leap.se/code/issues/866)


Deploying
---------

. If you have any errors during a run, please try to deploy again as this often solves non-deterministic issues that were not uncovered in our testing. Please re-deploy with `leap -v2 deploy` to get more verbose logs and capture the complete output to provide to us for debugging.

. If when deploying your debian mirror fails for some reason, network anomoly or the mirror itself is out of date, then platform deployment will not succeed properly. Check the mirror is up and try to deploy again when it is resolved (see: https://leap.se/code/issues/1091)

. Deployment gives 'error: in `%`: too few arguments (ArgumentError)' - this is because you attempted to do a deploy before initializing a node, please initialize the node first and then do a deploy afterwards (see: https://leap.se/code/issues/2550)

. This release has no ability to custom configure apt sources or proxies (see: https://leap.se/code/issues/1971)

. When running a deploy at a verbosity level of 2 and above, you will notice puppet deprecation warnings, these are known and we are working on fixing them

Special Environments
--------------------

. When deploying to OpenStack release "nova" or newer, you will need to do an initial deploy, then when it has finished run `leap facts update` and then deploy again (see: https://leap.se/code/issues/3020)

leap-mx
-------

. see https://github.com/leapcode/leap_mx#070 for issues regarding leap_mx


Contributing
============

In order to validate the syntax and style guide compliance
before you commit, see https://github.com/pixelated-project/puppet-git-hooks#installation


Changes
=========

Read CHANGES.md or run `git log`.

Authors and Credits
===================

See contributors:

    git shortlog -es --all


Copyright/License
=================

Read LICENSE
