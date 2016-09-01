Platform 0.8.2
--------------------------------------
This is a minor stability release of the 0.8.0 series of the LEAP Platform.

IMPORTANT: Please read the notes below in the following section for *critical*
information about upgrading from 0.7 releases. If you do not follow those
steps, this release will not work for you.

This release mainly fixes a potential security issue where VPN clients are able
to communicate with other connected VPN clients. It also fixes various other
minor issues that can be seen in the Issues fixed link below.

Because changes in this release are intended to be minor, there are no new
features included.

Commits: https://leap.se/git/leap_platform.git/shortlog/refs/tags/0.8.2
Issues fixed: https://leap.se/code/versions/210


Platform 0.8
--------------------------------------

This release focuses on the email service.

Requirements:
 . You must upgrade to Debian Jessie, see below for details
 . You must migrate all data from BigCouch to CouchDB
 . Soledad and couchdb services must be on the same node

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
