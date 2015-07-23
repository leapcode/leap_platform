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
