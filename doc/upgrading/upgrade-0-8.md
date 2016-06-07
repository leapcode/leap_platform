@title = 'Upgrade to 0.8'
@toc = false

LEAP Platform release 0.8 introduces several major changes that need do get taken into account while upgrading:

* Dropping Debian Wheezy support. You need to upgrade your nodes to jessie before deploying a platform upgrade.
* Dropping BigCouch support. LEAP Platform now requires CouchDB and therefore you need to migrate all your data from BigCouch to CouchDB.

Upgrading to Platform 0.8
---------------------------------------------

### Step 1: Get new leap_platform and leap_cli

    workstation$ gem install leap_cli --version 1.8
    workstation$ cd leap_platform
    workstation$ git pull
    workstation$ git checkout 0.8.0

### Step 2: Prepare to migrate from BigCouch to CouchDB

<%= render :partial => 'docs/platform/common/bigcouch_migration_begin.md' %>

### Step 3: Upgrade from Debian Wheezy to Jessie

There are the [Debian release notes on how to upgrade from wheezy to jessie](https://www.debian.org/releases/stable/amd64/release-notes/ch-upgrading.html). Here are the steps that worked for us, but please keep in mind that there is no bullet-proof method that will work in every situation. 

**USE AT YOUR OWN RISK.**

For each one of your nodes, login to it and do the following process:

    # keep a log of the progress:
    screen
    script -t 2>~/leap_upgrade-jessiestep.time -a ~/upgrade-jessiestep.script

    # ensure you have a good wheezy install:
    export DEBIAN_FRONTEND=noninteractive
    apt-get autoremove --yes
    apt-get update
    apt-get -y -o DPkg::Options::=--force-confold dist-upgrade

    # if either of these return anything, you will need to resolve them before continuing:
    dpkg --audit
    dpkg --get-selections | grep 'hold$'

    # switch sources to jessie
    sed -i 's/wheezy/jessie/g' /etc/apt/sources.list
    rm /etc/apt/sources.list.d/*
    echo "deb http://deb.leap.se/0.8 jessie main" > /etc/apt/sources.list.d/leap.list

    # remove pinnings to wheezy
    rm /etc/apt/preferences
    rm /etc/apt/preferences.d/*

    # get jessie package lists
    apt-get update

    # clean out old package files
    apt-get clean

    # test to see if you have enough space to upgrade, the following will alert
    # you if you do not have enough space, it will not do the actual upgrade
    apt-get -o APT::Get::Trivial-Only=true dist-upgrade

    # do first stage upgrade
    apt-get -y -o DPkg::Options::=--force-confold upgrade

    # repeat the following until it makes no more changes:
    apt-get -y -o DPkg::Options::=--force-confold dist-upgrade

    # resolve any apt issues if there are some
    apt-get -y -o DPkg::Options::=--force-confold -f install

    # clean up extra packages
    apt-get autoremove --yes

    reboot


Potential Jessie Upgrade Issues
-------------------------------

**W: Ignoring Provides line with DepCompareOp for package python-cffi-backend-api-max**

You can ignore these warnings, they will be resolved on upgrade.

**E: Unable to fetch some archives, maybe run apt-get update or try with --fix-missing?**

If you get this error, run `apt-get update` and then re-run the command.

**Unmet dependencies. Try using -f.**

Sometimes you might get an error similar to this (although the package names may be different):

    You might want to run 'apt-get -f install' to correct these.
    The following packages have unmet dependencies:
    lsof : Depends: libperl4-corelibs-perl but it is not installed or
                 perl (< 5.12.3-7) but 5.20.2-3+deb8u4 is installed

If this happens, run `apt-get -f install` to resolve it, and then re-do the previous upgrade command
you did when this happened.

**Failure restarting some services for OpenSSL upgrade**

If you get this warning:

    The following services could not be restarted for the OpenSSL library upgrade:
      postfix
    You will need to start these manually by running '/etc/init.d/<service> start'.

Just ignore it, it should be fixed on reboot/deploy.

### Step 4: Deploy LEAP Platform 0.8 to the Couch node

You will need to deploy the 0.8 version of LEAP Platform to the couch node before continuing. 

1. deploy to the couch node:

    ```
    workstation$ leap deploy <couchdb-node>
    ```

    If you used the iptables method of blocking access to couchdb, you need to run it again because the deploy just overwrote all the iptables rules:

    ```
    server# iptables -A INPUT -p tcp --dport 5984 --jump REJECT
    ```

### Step 5: Import Data into CouchDB

<%= render :partial => 'docs/platform/common/bigcouch_migration_end.md' %>

### Step 6: Deploy everything

Now that you've upgraded all nodes to Jessie, and migrated to CouchDB, you are ready to deploy LEAP Platform 0.8 to the rest of the nodes:

    workstation$ cd <provider directory>
    workstation$ leap deploy

### Step 7: Test and cleanup

<%= render :partial => 'docs/platform/common/bigcouch_migration_finish.md' %>
