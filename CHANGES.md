Platform 0.8
--------------------------------------

This release focused on the email service. Debian Jessie is now required,
which also means that you must migrate all data from BigCouch to CouchDB.

UPGRADING: It is tricky to upgrade the OS and migrate the database. You can
follow the tutorial here: https://leap.se/en/upgrade-0-8

WARNING: failure to migrate data from BigCouch to CouchDB will cause all user
accounts to get destroyed.

Other new features:

* It is possible to require invite codes for new users signing up.

* Tapicero has been removed. Now user storage databases are created as needed
  by soledad, and deleted eventually when no longer needed.

* Admins can now suspect/enable users and block/enable their ability to send
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
