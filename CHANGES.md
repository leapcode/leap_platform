Platform 0.7
-------------------------------------

CouchDB improvements: CouchDB is not designed to handle ephemeral data, like
sessions, because documents are never really deleted (a tombstone document is
always kept to record the deletion). To overcome this limitation, we now
rotate the `sessions` and `tokens` databases monthly. The new database names
are `tokens_XXX` and `sessions_XXX` where XXX is counter since the epoch that
increments every month (not a calendar month, but a month's worth of seconds).

Additionally, nagios monitor and `leap test run` now will create and destroy
test users in the `tmp_users` database, which will get periodically deleted
and recreated.

Compatibility:

* Requires leap_cli version 1.7
* Requires bitmask client version >= 0.7
* Previous releases supported cookies when using the provider API. Now, only tokens are supported.

Commits: https://leap.se/git/leap_platform.git/shortlog/refs/tags/0.7.0

Upgrading:

* `gem install leap_cli --version 1.7` or run leap_cli from current master branch.
* `cd leap_platform; git pull; git checkout 0.7.0` or checkout current master branch.
* `leap deploy`
* `leap db destroy --db sessions,tokens` You can ignore message about needing
  to redeploy (since, in this case, we just want to permanently delete those
  databases).

New features:

* rotating couchdb databases
* deployment logging: information on every deploy is logged to
  `/var/log/leap`, including the user, leap_cli version, and platform version.
* you must now run `leap deploy --downgrade` if you want to deploy an older
  version over a newer platform version.
* the install source each custom daemons (e.g. tapicero, etc) is now
  configured on `common.json`.
* you can configure apt sources in common.json
* many bug fixes

Platform 0.6
-------------------------------------

Compatibility:

* Requires leap_cli version 1.6
* Requires bitmask client version >= 0.5

Commits: https://leap.se/git/leap_platform.git/shortlog/refs/tags/0.6.0

New features:

* single node deployment
* include custom puppet modules and manifests
* couch flexibility
* stunnel rework
* new debian repository structure
* dependency pinning
* leap_cli modularization
* improved cert generation
* monitoring improvements such as per-environment tooling and notifications
* tor hidden service support
* switch away from NIST curve and ensure TLSv1 is used
* tests made significantly more robust
* add support for webapp deployment to a subdomain
* many, many bugfixes and stability improvements
