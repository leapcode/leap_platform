@title = 'Leap Platform Release Notes'
@nav_title = 'Known issues'
@summary = 'Known issues in the Leap Platform.'
@toc = true

Here you can find documentation about known issues and potential work-arounds in the current Leap Platform release.

0.6.0
==============

Upgrading
------------------

Upgrade your leap_platform to 0.6 and make sure you have the latest leap_cli.

**Update leap_platform:**

    cd leap_platform
    git pull
    git checkout -b 0.6.0 0.6.0 

**Update leap_cli:**

If it is installed as a gem from rubygems:

    sudo gem update leap_cli

If it is installed as a gem from source:

    cd leap_cli
    git pull
    git checkout master
    rake build
    sudo rake install

If it is run directly from source:

    cd leap_cli
    git pull
    git checkout master

To upgrade:

    leap --version  # must be at least 1.6.2
    leap cert update
    leap deploy
    leap test

If the tests fail, try deploying again. If a test fails because there are two tapicero daemons running, you need to ssh into the server, kill all the tapicero daemons manually, and then try deploying again (sometimes the daemon from platform 0.5 would put its PID file in an odd place).

OpenVPN
------------------

On deployment to a openvpn node, if the following happens:

    - err: /Stage[main]/Site_openvpn/Service[openvpn]/ensure: change from stopped to running failed: Could not start Service[openvpn]: Execution of '/etc/init.d/openvpn start' returned 1:  at /srv/leap/puppet/modules/site_openvpn/manifests/init.pp:189

this is likely the result of a kernel upgrade that happened during the deployment, requiring that the machine be restarted before this service can start. To confirm this, login to the node (leap ssh <nodename>) and look at the end of the /var/log/daemon.log:

    # tail /var/log/daemon.log
    Nov 22 19:04:15 snail ovpn-udp_config[16173]: ERROR: Cannot open TUN/TAP dev /dev/net/tun: No such device (errno=19)
    Nov 22 19:04:15 snail ovpn-udp_config[16173]: Exiting due to fatal error

if you see this error, simply restart the node.

CouchDB
---------------------

At the moment, we strongly advise only have one bigcouch server for stability purposes.

With multiple couch nodes (not recommended at this time), in some scenarios, such as when certain components are unavailable, the couchdb syncing will be broken. When things are brought back to normal, shortly after restart, the nodes will attempt to resync all their data, and can fail to complete this process because they run out of file descriptors. A symptom of this is the webapp wont allow you to register or login, the /opt/bigcouch/var/log/bigcouch.log is huge with a lot of errors that include (over multiple lines): {error,  emfile}}. We have raised the limits for available file descriptors to bigcouch to try and accommodate for this situation, but if you still experience it, you may need to increase your /etc/sv/bigcouch/run ulimit values and restart bigcouch while monitoring the open file descriptors. We hope that in the next platform release, a newer couchdb will be better at handling these resources.

You can also see the number of file descriptors in use by doing:

    # watch -n1 -d lsof -p `pidof beam`|wc -l

The command `leap db destroy` will not automatically recreate new databases. You must run `leap deploy` afterwards for this.

User setup and ssh
------------------

At the moment, it is only possible to add an admin who will have access to all LEAP servers (see: https://leap.se/code/issues/2280)

The command `leap add-user --self` allows only one SSH key. If you want to specify more than one key for a user, you can do it manually:

    users/userx/userx_ssh.pub
    users/userx/otherkey_ssh.pub

All keys matching 'userx/*_ssh.pub' will be used for that user.

Deploying
---------

If you have any errors during a run, please try to deploy again as this often solves non-deterministic issues that were not uncovered in our testing. Please re-deploy with `leap -v2 deploy` to get more verbose logs and capture the complete output to provide to us for debugging.

If when deploying your debian mirror fails for some reason, network anomoly or the mirror itself is out of date, then platform deployment will not succeed properly. Check the mirror is up and try to deploy again when it is resolved (see: https://leap.se/code/issues/1091)

Deployment gives 'error: in `%`: too few arguments (ArgumentError)' - this is because you attempted to do a deploy before initializing a node, please initialize the node first and then do a deploy afterwards (see: https://leap.se/code/issues/2550)

This release has no ability to custom configure apt sources or proxies (see: https://leap.se/code/issues/1971)

When running a deploy at a verbosity level of 2 and above, you will notice puppet deprecation warnings, these are known and we are working on fixing them

IPv6
----

As of this release, IPv6 is not supported by the VPN configuration. If IPv6 is detected on your network as a client, it is blocked and instead it should revert to IPv4. We plan on adding IPv6 support in an upcoming release.


Special Environments
--------------------

When deploying to OpenStack release "nova" or newer, you will need to do an initial deploy, then when it has finished run `leap facts update` and then deploy again (see: https://leap.se/code/issues/3020)

It is not possible to actually use the EIP openvpn server on vagrant nodes (see: https://leap.se/code/issues/2401)
