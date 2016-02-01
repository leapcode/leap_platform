Platform 0.8
--------------------------------------

This release focused on the email service. Additionally, almost all the code
for leap_cli has been moved to leap_platform.

* It is possible to require invite codes for new users signing up.

* Tapicero has been removed. Now user storage databases are created as needed
  by soledad, and deleted eventually when no longer needed.

* Bigcouch is now officially deprecated. New nodes created with `leap node add
  services:couchdb` will default to using plain CouchDB.
  It is highly recommended that you run a single couchdb node.
  

* Admins can now suspect/enable users and block/enable their ability to send
  and receive email.

* Support for SPF and DKIM.

Compatibility:

* Now, soledad and couchdb must be on the same node.
* Requires Debian Jessie. Wheezy is no longer supported.
* Requires leap_cli version 1.8
* Requires bitmask client version >= 0.9
* Includes:
  * leap_mx 0.8
  * webapp 0.8
  * soledad 0.8

Commits: https://leap.se/git/leap_platform.git/shortlog/refs/tags/0.8
Issues fixed: https://leap.se/code/versions/189

Upgrading:

* To migrate data to use plain couchdb, see
  https://leap.se/en/docs/platform/services/couchdb#use-plain-couchdb-instead-of-bigcouch
  This is still optional, but is a good idea.

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
