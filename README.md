Leap Platform
=============================

[![Build Status](https://0xacab.org/leap/platform/badges/master/build.svg)](https://0xacab.org/leap/platform/commits/master)

The LEAP Platform is set of complementary packages and server recipes to
automate the maintenance of LEAP services in a hardened Debian environment. Its
goal is to make it as painless as possible for sysadmins to deploy and maintain
a service provider's infrastructure for secure communication. These recipes
define an abstract service provider. It is a set of Puppet modules designed to
work together to provide to sysadmins everything they need to manage a service
provider infrastructure that provides secure communication services.

Getting started
=============================

It is highly recommended that you start by reading the overview of the [LEAP
Platform](https://leap.se/docs/platform) and then begin with the [Quick Start
tutorial](https://leap.se/en/docs/platform/tutorials/quick-start) to walk
through a test environment setup to get familiar with how things work before
deploying to live servers.

An offline copy of this documentation is contained in the `docs` subdirectory:

    cd leap_platform
    gnome-open docs/index.html

Requirements
-----------------------------

For testing a virtual deployment simulated on your computer, you will need a
fairly recent computer x86_64 with hardware virtualization features (AMD-V or
VT-x) and plenty of RAM. If you follow the "Quick Start" documentation we will
walk you through using Vagrant to setup a test deployment.

For a live deployment of the platform, the number of servers that is required
depends on your needs and which services you want to deploy. At the moment, the
LEAP Platform supports servers with a base Debian Jessie installation.

Upgrading
=============================

If you are upgrading from a previous version of the LEAP Platform, take special
care to follow the instructions detailed in the CHANGES.md to move from one
release to the next.

Troubleshooting
=============================

If you have a problem, we are interested in fixing it!

If you have a problem, be sure to have a look at the [Known
Issues](https://leap.se/docs/platform/known-issues) to see if your issue is
detailed there.

If not, the best way for us to solve your problem is if you provide to us the
complete log of what you did, and the output that was produced. Please don't
cut out what appears to be useless information and only include the error that
you received, instead copy and paste the complete log so that we can better
determine the overall situation. If you can run the same command that produced
the error with a raised verbosity level (such as -v2), that provides us with
more useful debugging information.

To capture the log, you can copy from the console, or run `leap --log FILE` or
edit Leapfile to include `@log = '/tmp/leap.log'`.

Visit https://leap.se/en/docs/get-involved/communication for details on how to
contact the developers.

Known issues
==============================

ssh
------------------------------

* At the moment, it is only possible to add an admin who will have access to
  all LEAP servers (see: https://leap.se/code/issues/2280)

Deploying
-------------------------------

* If you have any errors during a run, please try to deploy again as this often
  solves non-deterministic issues that were not uncovered in our testing.
  Please re-deploy with `leap -v2 deploy` to get more verbose logs and capture
  the complete output to provide to us for debugging.

Contributing
================================

Run rake tests
--------------

    cd tests/platform-ci
    ./setup.sh
    bundle exec rake lint
    bundle exec rake syntax
    bundle exec rake validate
    bundle exec rake templates
    bundle exec rake catalog

Merge requests
--------------

In order to validate the syntax and style guide compliance before you commit,
see https://github.com/pixelated-project/puppet-git-hooks#installation
Please fork https://0xacab.org/leap/platform to open a merge request,
and pick the `Platform runner (greyhound)` at https://0xacab.org/YOUR_USERNAME/platform/runners
in order to run a CI build for your merge request.

Changes
================================

Read CHANGES.md or run `git log`.

Authors and Credits
================================

See contributors:

    git shortlog -es --all


Copyright/License
================================

Read LICENSE
