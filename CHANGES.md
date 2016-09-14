Platform 0.9
--------------------------------------

The focus for Platform 0.9 was to clean house: we replaced the annoying system
of puppet submodules, we cleaned up the directory structure, we removed many of
the gem dependencies, and we fixed a lot of bugs.

New Features:

* `leap vm` -- Support for managing remote virtual servers (AWS only, for now)
* `leap cert renew` -- Integration with Let's Encrypt
* improved documentation -- open docs/index.html to see

Notable Changes:

* 58 bugs fixed
* Fixed security issues with VPN
* More tests
* Replaced git submodules with git subrepo
* Nearly all the leap_cli code has been moved to leap_platform.git
* Better organization of the leap_platform.git directory structure
* Removed ugly dependency on Capistrano

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
