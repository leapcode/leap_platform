Platform 0.10
------------------------------------------------

The main focus for Platform 0.10 was to update of all client-side daemons to
newest releases, like Soledad and OpenVPN. This introduces a *compatibility
change*: by setting the platform version to 0.10, it also requires client 0.9.4
or later. We also switched the development branch to the 'master' branch and are
creating a branch called 0.10.x to push hot-fixes during the 0.10 life-cycle.

Note: This will be the last major release of the LEAP Platform for Debian
Jessie. We will continue to support 0.10 with minor releases with important
security and bug fixes, but the next major release will require an upgrade to
Stretch.

New Features:

* Tor single-hop onion service capability.
* `leap info` is now run after deploy
* Timestamps are added to deployments
* Missing ssh host keys are generated on node init
* Private networking support for local Vagrant development
* Static sites get lets encrypt support
* add command `leap node disable`, `leap node enable`, `leap ping`

Notable Changes:

* Removed haproxy because we don't support multi-node couchdb installations anymore (#8144).
* Disable nagios notification emails (#8772).
* Fix layout of apt repository (#8888)
* Limit what archive signing keys are accepted for the leap debian repository packages (#8425).
* Monitor the Webapp logs for errors (#5174).
* Moved development to the master branch.
* Rewrite leap_cli ssh code
* Debian wheezy was fully deprecated
* Restructure package archives to enable auto packaging, and CI testing
* Significant CI improvements
* Troubleshooting information added to `leap user ls`
* Couchdb service is no longer required on soledad nodes (#8693)
* Tor service refactored (#8864), and v3 hidden service support added (#8879)
* Fixed unattended-upgrades (#8891)
* Alert on 409 responses for webapp
* Many other issues resolved, full list: https://0xacab.org/groups/leap/milestones/platform-010?title=Platform+0.10

Upgrading:

If you have a node with the service 'tor' defined, you will need to change it to
be either 'tor-relay', or 'tor-exit'. Look in your provider directory under the
nodes directory for any .json file that has a 'services' section with 'tor'
defined, change that to the correct tor service you are wanting to deploy.

Make sure you have the correct version of leap_cli

    workstation$ sudo gem install leap_cli --version=1.9

If you are upgrading from a version previous to 0.9, please follow those upgrade
instructions before upgrading to 0.10.

Prepare your platform source by checking out the 0.10.x branch:

    workstation$ cd leap_platform
    workstation$ git fetch
    workstation$ git checkout 0.10.x

Then, deploy:

    workstation$ cd $PROVIDER_DIR
    workstation$ leap deploy
    workstation$ leap test

After deployment, if the leap test does not succeed, you should
investigate. Please see below for some post-deployment upgrade steps that you
may need to perform.

Starting with Soledad Server 0.9.0, the CouchDB database schema was changed to
improve speed of the server side storage backend. If you provided email, you
will need to run the migration script, otherwise it is unnecessary. Until you
migrate, soledad will refuse to start.

To run the migration script, do the following (replacing $PROVIDER_DIR,
$COUCHDB_NODE, $MX_NODE, and $SOLEDAD_NODE with your values):

First backup your couchdb databases, just to be safe. NOTE: This can take some
time and will place several hundred megabytes of data into
/var/backups/couchdb. The size and time depends on how many users there are on
your system. For example, 15k users took approximately 25 minutes and 308M of
space:

    workstation$ leap ssh $COUCHDB_NODE
    server# cd /srv/leap/couchdb/scripts
    server# ./cleanup-user-dbs
    server# time ./couchdb_dumpall.sh

 Once that has finished, then its time to run the migration:

    workstation$ cd $PROVIDER_DIR
    workstation$ leap run 'systemctl leap_mx stop' $MX_NODE
    workstation$ leap run --stream '/usr/share/soledad-server/migration/0.9/migrate.py --log-file /var/log/leap/soledad_migration --verbose --do-migrate' $SOLEDAD_NODE
    wait for it to finish (will print DONE)
    rerun if interrupted
    workstation$ leap deploy
    workstation$ leap test

Known Issues:

If you have been deploying from our master branch (ie: unstable code), you might
end up with a broken sources line for apt. If you get the following:
    WARNING: The following packages cannot be authenticated!

Then you should remove the files on your nodes inside
/var/lib/puppet/modules/apt/keys and deploy again. (#8862, #8876)

* When upgrading, sometimes systemd does not report the correct state of a
  daemon. The daemon will be not running, but systemd thinks it is. The symptom
  of this is that a deploy will succeed but `leap test` will fail. To fix, you
  can run `systemctl stop DAEMON` and then `systemctl start DAEMON` on the
  affected host (systemctl restart seems to work less reliably).

Includes:

* leap_web: 0.9.2
* nickserver: 0.10.0
* leap-mx: 0.10.1
* soledad-server: 0.10.5

Commits: https://0xacab.org/groups/leap/milestones/platform-010?title=Platform+0.10

For details on about all the changes included in this release please consult the
[LEAP platform 0.10 milestone](https://0xacab.org/leap/platform/milestones/7 ).


Platform 0.9
--------------------------------------

The focus for Platform 0.9 was to clean house: we replaced the annoying system
of puppet submodules, we cleaned up the directory structure, we removed many of
the gem dependencies, and we fixed a lot of bugs.

New Features:

* `leap vm` -- Support for managing remote virtual servers (AWS only, for now)
* `leap cert renew` -- Integration with Let's Encrypt
* `leap open monitor` -- for handy access to nagios
* improved documentation -- open docs/index.html to see

Notable Changes:

* 86 bugs fixed
* Fixed security issues with VPN
* More tests
* Replaced git submodules with git subrepo
* Nearly all the leap_cli code has been moved to leap_platform.git
* Command-line leap_cli cleanup to be more logically consistent
* Better organization of the leap_platform.git directory structure
* Removed ugly dependency on Capistrano
* Enabled DANE/TLSA validation
* Anti-spam improvements
* Performance improvements for couchdb
* Change from httpredir.debian.org to deb.debian.org
* Reduce duplicated logging

Upgrading:

You will need the new version of leap_cli:

    workstation$ sudo gem install leap_cli --version=1.9

Because 0.9 does not use submodules anymore, you must remove them before pulling
the latest leap_platform from git:

    workstation$ cd leap_platform
    workstation$ for dir in $(git submodule | awk '{print $2}'); do
    workstation$   git submodule deinit $dir
    workstation$ done
    workstation$ git pull
    workstation$ git checkout 0.9.0

Alternately, just clone a fresh leap_platform:

    workstation$ git clone https://leap.se/git/leap_platform
    workstation$ cd leap_platform
    workstation$ git checkout 0.9.0

Then, deploy:

    workstation$ cd PROVIDER_DIR
    workstation$ leap deploy

Known Issues:

* When upgrading, sometimes systemd does not report the correct state of a
  daemon. The daemon will be not running, but systemd thinks it is. The symptom
  of this is that a deploy will succeed but `leap test` will fail. To fix, you
  can run `systemctl stop DAEMON` and then `systemctl start DAEMON` on the
  affected host (systemctl restart seems to work less reliably).

Includes:

* leap_web: 0.8
* nickserver: 0.8
* couchdb: 1.6.0
* leap-mx: 0.8.1
* soledad-server: 0.8.0

Commits: https://leap.se/git/leap_platform.git/shortlog/refs/tags/0.9

Issues fixed: https://leap.se/code/versions/195


Platform 0.8
--------------------------------------

This release focuses on the email service.

Requirements:

* You must upgrade to Debian Jessie, see below for details
* You must migrate all data from BigCouch to CouchDB
* Soledad and couchdb services must be on the same node

WARNING: failure to migrate data from BigCouch to CouchDB will cause all user
accounts to get destroyed. See UPGRADING below for how to safely do this.

UPGRADING: You must upgrade to Debian Jessie and migrate from BigCouch to
Couchdb. It is tricky to upgrade the OS and migrate the database, so we have
writen and tested a step-by-step guide that you can carefully follow in
doc/upgrading/upgrade-0-8.md, or online at: https://leap.se/en/upgrade-0-8

Other new features:

* It is possible to require invite codes for new users signing up.

* Tapicero has been removed. Now user storage databases are created as needed
  by soledad, and deleted eventually when no longer needed.

* Admins can now suspend/enable users and block/enable their ability to send
  and receive email.

* Support for SPF and DKIM.

Compatibility:

* Now, soledad and couchdb must be on the same node.
* Requires Debian Jessie. Wheezy is no longer supported.
* Requires CouchDB, BigCouch is no longer supported.
* Requires leap_cli version 1.8
* Requires bitmask client version >= 0.9
* Includes:
  * leap_mx 0.8
  * webapp 0.8
  * soledad 0.8

Commits: https://leap.se/git/leap_platform.git/shortlog/refs/tags/0.8
Issues fixed: https://leap.se/code/versions/189


Platform 0.7.1
--------------------------------------

Compatibility:

* Requires leap_cli version 1.7.4
* Requires bitmask client version >= 0.7
* Previous releases supported cookies when using the provider API. Now, only
  tokens are supported.
* Includes:
  * leap_mx 0.7.0
  * tapicero 0.7
  * webapp 0.7
  * soledad 0.7

Commits: https://leap.se/git/leap_platform.git/shortlog/refs/tags/0.7.1
Issues fixed: https://leap.se/code/versions/159

Upgrading:

* `gem install leap_cli --version 1.7.4`.
* `cd leap_platform; git pull; git checkout 0.7.1`.
* `leap deploy`
* `leap test` to make sure everything is working
