Platform 0.8
-----------------------

This release focuses on many improvements to email service.

* It is possible to require invite codes for new users signing up.
* Admins can now suspect/enable users and block/enable their ability to send
  and receive email.
* Bigcouch is now officially deprecated. New nodes created with `leap node add
  services:couchdb` will default to using plain CouchDB.
* Support for SPF and DKIM.

Compatibility:

* Tapicero has been removed. Now, soledad and couchdb must be on the same node.
* Requires Debian Jessie. Wheezy is no longer supported.
* Includes:
  * webapp 0.8

Platform 0.7.1
-----------------------

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
