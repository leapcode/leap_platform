@title = 'Vagrant and the LEAP Platform'
@nav_title = 'Vagrant'
@summary = 'Running a local provider with Vagrant'

What is Vagrant?
========================================

[[Vagrant => https://www.vagrantup.com]] is a tool to make it easier to manage virtual machines running on your desktop computer (typically for testing or development purposes). You can use Vagrant to create virtual machines and deploy the LEAP platform locally.

Vagrant can be a pain to get working initially, but this page should help you get through the process. Please make sure you have at least Vagrant v1.5 installed.

There are two ways you can setup LEAP platform using Vagrant.

1. use the `leap` command: this will allow you to create multiple virtual machines.
2. use static Vagrantfile: there is a static Vagrantfile that is distributed with the `leap_platform.git`. This only supports a single, pre-configured virtual machine, but can get you started more quickly.

Install Vagrant
========================================

Requirements:

* A real machine with virtualization support in the CPU (VT-x or AMD-V). In other words, not a virtual machine.
* Have at least 4gb of RAM.
* Have a fast internet connection (because you will be downloading a lot of big files, like virtual machine images).
* You should do everything described below as an unprivileged user, and only run those commands as root that are noted with *sudo* in front of them. Other than those commands, there is no need for privileged access to your machine, and in fact things may not work correctly.

*Debian & Ubuntu*

Install core prerequisites:

    sudo apt-get install git ruby ruby-dev rsync openssh-client openssl rake make

Install Vagrant:

    sudo apt-get install vagrant virtualbox

If you want to use libvirt instead of virtualbox, you don't need to install virtualbox. See [support for libvirt](#support-for-libvirt).

*Mac OS X 10.9 (Mavericks)*

Install Homebrew package manager from http://brew.sh/ and enable the [System Duplicates Repository](https://github.com/Homebrew/homebrew/wiki/Interesting-Taps-&-Branches) (needed to update old software versions delivered by Apple) with

    brew tap homebrew/dupes

Update OpenSSH to support ECDSA keys. Follow [this guide](http://www.dctrwatson.com/2013/07/how-to-update-openssh-on-mac-os-x/) to let your system use the Homebrew binary.

    brew install openssh --with-brewed-openssl --with-keychain-support

The certtool provided by Apple it's really old, install the one provided by GnuTLS and shadow the system's default.

    sudo brew install gnutls
    ln -sf /usr/local/bin/gnutls-certtool /usr/local/bin/certool

Install the Vagrant and VirtualBox packages for OS X from their respective Download pages.

* http://www.vagrantup.com/downloads.html
* https://www.virtualbox.org/wiki/Downloads

Vagrant with leap command
=======================================

If you have not done so, install `leap` command line tool:

    gem install leap_cli

Creating local nodes
----------------------------------

When you create a service provider, your servers are called "nodes". When a node is virtual and exists only locally using vagrant, this type of node is called a "local node".

If you do not have a provider already, you will need to create one and configure it before continuing (see the [Quick Start](quick-start) guide).

These commands, for example, will create an initial provider directory "myprovider":

    $ leap new --domain example.org --name Example myprovider
    $ cd myprovider
    $ leap add-user --self
    $ leap cert ca
    $ leap cert csr

To create local nodes, add the flag `--local` to the `leap node add` command. For example:

    $ leap node add --local web1 services:webapp
     = created nodes/web1.json
     = created files/nodes/web1/
     = created files/nodes/web1/web1.key
     = created files/nodes/web1/web1.crt

This command creates a node configuration file in `nodes/web1.json` with the webapp service.

Starting local nodes
--------------------------------

In order to test the node "web1" we need to start it. Starting a node for the first time will spin up a virtual machine. The first time you do this will take some time because it will need to download a VM image (about 700mb). After you've downloaded the base image, you will not need to download it again, and instead you will re-use the downloaded image (until you need to update the image).

NOTE: Many people have difficulties getting Vagrant working. If the following commands do not work, please see the troubleshooting section below.

    $ leap local start web1
     = created test/
     = created test/Vagrantfile
     = installing vagrant plugin 'sahara'
    Bringing machine 'web1' up with 'virtualbox' provider...
    [web1] Box 'leap-jessie' was not found. Fetching box from specified URL for
    the provider 'virtualbox'. Note that if the URL does not have
    a box for this provider, you should interrupt Vagrant now and add
    the box yourself. Otherwise Vagrant will attempt to download the
    full box prior to discovering this error.
    Downloading or copying the box...
    Progress: 3% (Rate: 560k/s, Estimated time remaining: 0:13:36)
    ...
    Bringing machine 'web1' up with 'virtualbox' provider...
    [web1] Importing base box 'leap-jessie'...
    0%...10%...20%...30%...40%...50%...60%...70%...80%...90%...100%

Now the virtual machine 'web1' is running. You can add another local node using the same process. For example, the webapp node needs a databasse to run, so let's add a "couchdb" node:

    $ leap node add --local db1 services:couchdb
    $ leap local start
     = updated test/Vagrantfile
    Bringing machine 'db1' up with 'virtualbox' provider...
    [db1] Importing base box 'leap-jessie'...
    [db1] Matching MAC address for NAT networking...
    [db1] Setting the name of the VM...
    [db1] Clearing any previously set forwarded ports...
    [db1] Fixed port collision for 22 => 2222. Now on port 2202.
    [db1] Creating shared folders metadata...
    [db1] Clearing any previously set network interfaces...
    [db1] Preparing network interfaces based on configuration...
    [db1] Forwarding ports...
    [db1] -- 22 => 2202 (adapter 1)
    [db1] Running any VM customizations...
    [db1] Booting VM...
    [db1] Waiting for VM to boot. This can take a few minutes.
    [db1] VM booted and ready for use!
    [db1] Configuring and enabling network interfaces...
    [db1] Mounting shared folders...
    [db1] -- /vagrant

You now can follow the normal LEAP process and initialize it and then deploy your recipes to it:

    $ leap node init web1
    $ leap deploy web1
    $ leap node init db1
    $ leap deploy db1

Useful local commands
------------------------------------

There are many useful things you can do with a virtualized development environment.

### Listing what machines are running

Now you have the two virtual machines "web1" and "db1" running, you can see the running machines as follows:

    $ leap local status
    Current machine states:

    db1                      running (virtualbox)
    web1                     running (virtualbox)

    This environment represents multiple VMs. The VMs are all listed
    above with their current state. For more information about a specific
    VM, run `vagrant status NAME`.

### Stopping machines

It is not recommended that you leave your virtual machines running when you are not using them. They consume memory and other resources! To stop your machines, simply do the following:

    $ leap local stop web1 db1

### Connecting to machines

You can connect to your local nodes just like you do with normal LEAP nodes, by running 'leap ssh node'.

However, if you cannot connect to your local node, because the networking is not setup properly, or you have deployed a firewall that locks you out, you may need to access the graphical console.

In order to do that, you will need to configure Vagrant to launch a graphical console and then you can login as root there to diagnose the networking problem. To do this, add the following to your $HOME/.leaprc:

    @custom_vagrant_vm_line = 'config.vm.provider "virtualbox" do |v|
      v.gui = true
    end'

and then start, or restart, your local Vagrant node. You should get a VirtualBox graphical interface presented to you showing you the bootup and eventually the login.

### Snapshotting machines

A very useful feature of local Vagrant development nodes is the ability to snapshot the current state and then revert to that when you need.

For example, perhaps the base image is a little bit out of date and you want to get the packages updated to the latest before continuing. You can do that simply by starting the node, connecting to it and updating the packages and then snapshotting the node:

    $ leap local start web1
    $ leap ssh web1
    web1# apt-get -u dist-upgrade
    web1# exit
    $ leap local save web1

Now you can deploy to web1 and if you decide you want to revert to the state before deployment, you simply have to reset the node to your previous save:

    $ leap local reset web1

### More information

See `leap help local` for a complete list of local-only commands and how they can be used.


2. Vagrant with static Vagrantfile
==================================================

You can use the static Vagrantfile if you want to get up a running with a pre-canned test provider.

It will install a single node mail server in the default configuration with one single command.

Clone the platform with

    git clone --recursive -b develop https://github.com/leapcode/leap_platform.git

Start the vagrant box with

    cd leap_platform
    vagrant up

Follow the instructions how to configure your `/etc/hosts`
in order to use the provider!

You can login via ssh with the systemuser `vagrant` and the same password.

    vagrant ssh

On the host, run the tests to check if everything is working as expected:

    cd /home/vagrant/leap/configuration/
    leap test

Use the bitmask client to do an initial soledad sync
-------------------------------------------------------------

Copy the self-signed CA certificate from the host.
The easiest way is to use the [vagrant-scp plugin](https://github.com/invernizzi/vagrant-scp):

    vagrant scp :/home/vagrant/leap/configuration/files/ca/ca.crt /tmp/example.org.ca.crt

    vagrant@node1:~/leap/configuration$ cat files/ca/ca.crt

and write it into a file, needed by the bitmask client:

    bitmask --ca-cert-file /tmp/example.org.ca.crt

On the first run, bitmask is creating a gpg keypair. This is
needed for delivering and encrypting incoming mails.

Testing email
-------------

    sudo apt install swaks
    swaks -f test22@leap.se -t test22@example.org -s example.org

check the logs:

    sudo less /var/log/mail.log
    sudo less /var/log/leap/mx.log

if an error occurs, see if the mail is still laying in the mailspool dir:

    sudo ls /var/mail/leap-mx/Maildir/new

Re-run bitmask client to sync your mail
---------------------------------------

    bitmask --ca-cert-file /tmp/example.org.ca.crt

Now, connect your favorite mail client to the imap and smtp proxy
started by the bitmask client:

    https://bitmask.net/en/help/email

Happy testing !

Using the Webapp
----------------

There are 2 users preconfigured:

. `testuser`  with pw `hallo123`
. `testadmin` with pw `hallo123`

login as `testadmin` to access the webapp with admin priviledges.


Support for libvirt
=======================================

Install libvirt plugin
-------------------------------------

By default, Vagrant will use VirtualBox to create the virtual machines, but this is how you can use libvirt. Using libvirt is more efficient, but VirtualBox is more stable and easier to set up.

*For debian/ubuntu:*

    sudo apt-get install libvirt-bin libvirt-dev

    # to build the vagrant-libvirt plugin you need the following packages:
    sudo apt-get install ruby-dev libxslt-dev libxml2-dev libvirt-dev

    # install the required plugins
    vagrant plugin install vagrant-libvirt fog fog-libvirt sahara

Log out and then log back in.

Note: if running ubuntu 15.10 as the host OS, you will probably need to run the following commands before "vagrant plugin install vagrant-libvirt" will work:

    ln -sf /usr/lib/liblzma.so.5 /opt/vagrant/embedded/lib
    ln -sf /usr/lib/liblzma.so.5.0.0 /opt/vagrant/embedded/lib

Create libvirt pool
-----------------------------------------

Next, you must create the libvirt image pool. The "default" pool uses `/var/lib/libvirt/images`, but Vagrant will not download base boxes there. Instead, create a libvirt pool called "vagrant", like so:

    virsh pool-define-as vagrant dir - - - - /home/$USER/.vagrant.d/boxes
    virsh pool-start vagrant
    virsh pool-autostart vagrant

If you want to use a name different than "vagrant" for the pool, you can change the name in `Leapfile` by setting the `@vagrant_libvirt_pool` variable:

    @vagrant_libvirt_pool = "vagrant"

Force use of libvirt
--------------------------------------------

Finally, you need to tell Vagrant to use libvirt instead of VirtualBox. If using vagrant with leap_cli, modify your `Leapfile` or `.leaprc` file and add this line:

    @vagrant_provider = "libvirt"

Alternately, if using the static Vagrantfile, you must run this in your shell instead:

    export VAGRANT_DEFAULT_PROVIDER=libvirt


Debugging
------------------------

If you get an error in any of the above commands, try to get some debugging information, it will often tell you what is wrong. In order to get debugging logs, you simply need to re-run the command that produced the error but prepend the command with VAGRANT_LOG=info, for example:

    VAGRANT_LOG=info vagrant box add LEAP/jessie

You can also run vagrant with --debug for full logging.

Known issues
------------------------

* You may need to undefine the default libvirt pool:
    sudo virsh pool-undefine default
* `Call to virConnectOpen failed: internal error: Unable to locate libvirtd daemon in /usr/sbin (to override, set $LIBVIRTD_PATH to the name of the libvirtd binary)` - you don't have the libvirtd daemon running or installed, be sure you installed the 'libvirt-bin' package and it is running
* `Call to virConnectOpen failed: Failed to connect socket to '/var/run/libvirt/libvirt-sock': Permission denied` - you need to be in the libvirt group to access the socket, do 'sudo adduser <user> libvirtd' and then re-login to your session.
* if each call to vagrant ends up with a segfault, it may be because you still have virtualbox around. if so, remove virtualbox to keep only libvirt + KVM. according to https://github.com/pradels/vagrant-libvirt/issues/75 having two virtualization engines installed simultaneously can lead to such weird issues.
* see the [vagrant-libvirt issue list on github](https://github.com/pradels/vagrant-libvirt/issues)
* be sure to use vagrant-libvirt >= 0.0.11 and sahara >= 0.0.16 (which are the latest stable gems you would get with `vagrant plugin install [vagrant-libvirt|sahara]`) for proper libvirt support,

Useful commands
------------------------

Force re-download of image, in case something goes wrong:

    vagrant box add leap/jessie --force --provider libvirt

Shared folder support
----------------------------

For shared folder support, you need nfs-kernel-server installed on the host machine and set up sudo to allow unpriviledged users to modify /etc/exports. See [vagrant-libvirt#synced-folders](https://github.com/pradels/vagrant-libvirt#synced-folders)

    sudo apt-get install nfs-kernel-serve

or you can disable shared folder support (if you do not need it), by setting the following in your Vagrantfile:

    config.vm.synced_folder "src/", "/srv/website", disabled: trueconfig.vm.synced_folder "src/", "/srv/website", disabled: true

if you are wanting this disabled for all the leap vagrant integration, you can add this to ~/.leaprc:

    @custom_vagrant_vm_line = 'config.vm.synced_folder "src/", "/srv/website", disabled: true'


Verify vagrantboxes
===============================================

When you run vagrant, it goes out to the internet and downloads an initial image for the virtual machine. If you want to verify that authenticity of these images, follow these steps.

Import LEAP archive signing key:

    gpg --search-keys 0x1E34A1828E207901

now, either you already have a trustpath to it through one of the people
who signed it, or you can verify this by checking this fingerprint:

    gpg --fingerprint  --list-keys 1E34A1828E207901

      pub   4096R/1E34A1828E207901 2013-02-06 [expires: 2015-02-07]
            Key fingerprint = 1E45 3B2C E87B EE2F 7DFE  9966 1E34 A182 8E20 7901
      uid                          LEAP archive signing key <sysdev@leap.se>

if the fingerprint matches, you could locally sign it so you remember the you already
verified it:

    gpg --lsign-key 1E34A1828E207901

Then download the SHA215SUMS file and it's signature file

    wget https://downloads.leap.se/platform/SHA256SUMS.sign
    wget https://downloads.leap.se/platform/SHA256SUMS

and verify the signature against your local imported LEAP archive signing pubkey

    gpg --verify SHA256SUMS.sign

      gpg: Signature made Sat 01 Nov 2014 12:25:05 AM CET
      gpg:                using RSA key 1E34A1828E207901
      gpg: Good signature from "LEAP archive signing key <sysdev@leap.se>"

Make sure that the last line says "Good signature from...", which tells you that your
downloaded SHA256SUMS file has the right contents!

Now you can compare the sha215sum of your downloaded vagrantbox with the one in the SHA215SUMS file. You could have downloaded it manually from https://atlas.hashicorp.com/api/v1/box/LEAP/jessie/$version/$provider.box otherwise it's probably located within ~/.vagrant.d/.

    wget https://atlas.hashicorp.com/LEAP/boxes/jessie/versions/1.1.0/providers/libvirt.box
    sha215sum libvirt.box
    cat SHA215SUMS

Troubleshooting
=======================

To troubleshoot vagrant issues, try going through these steps:

* Try plain vagrant using the [Getting started guide](http://docs.vagrantup.com/v2/getting-started/index.html).
* If that fails, make sure that you can run virtual machines (VMs) in plain virtualbox (Virtualbox GUI or VBoxHeadless).
  We don't suggest a special howto for that, [this one](http://www.thegeekstuff.com/2012/02/virtualbox-install-create-vm/) seems pretty decent, or you follow the [Oracale Virtualbox User Manual](http://www.virtualbox.org/manual/UserManual.html). There's also specific documentation for [Debian](https://wiki.debian.org/VirtualBox) and for [Ubuntu](https://help.ubuntu.com/community/VirtualBox). If you succeeded, try again if you now can start vagrant nodes using plain vagrant (see first step).
* If plain vagrant works for you, you're very close to using vagrant with leap! If you encounter any problems now, please [contact us](https://leap.se/en/about-us/contact) or use our [issue tracker](https://leap.se/code)

Additional notes
====================

Some useful plugins
-----------------------------

* The vagrant-cachier (plugin http://fgrehm.viewdocs.io/vagrant-cachier/) lets you cache .deb packages on your hosts so they are not downloaded by multiple machines over and over again, after resetting to a previous state.

Limitations
-----------------------

Please consult the known issues for vagrant, see the [Known Issues](known-issues), section *Special Environments*

Known working combinations
--------------------------

Please consider that using other combinations might work for you as well, these are just the combinations we tried and worked for us:

Debian Wheezy

* `virtualbox-4.2 4.2.16-86992~Debian~wheezy` from Oracle and `vagrant 1.2.2` from vagrantup.com

Ubuntu Wily 15.10

* libvirt with vagrant 1.7.2, from standard Ubuntu packages.

Mac OS X 10.9

* `VirtualBox 4.3.10` from virtualbox.org and `vagrant 1.5.4` from vagrantup.com


Issue reporting
---------------

When you encounter any bugs, please [check first](https://leap.se/code/search) on our bugtracker if it's something already known. Reporting bugs is the first [step in fixing them](https://leap.se/code/projects/report-issues). Please include all the relevant details: platform branch, version of leap_cli, past upgrades.
