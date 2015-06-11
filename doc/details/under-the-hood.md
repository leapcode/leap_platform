@title = "Under the hood"
@summary = "Various implementation details."

This page contains various details on the how the platform is implemented. You can safely ignore this page, although it may be useful if you plan to make modifications to the platform.

Puppet Details
======================================

Tags
----

Tags are beeing used to deploy different classes.

* leap_base:    site_config::default (configure hostname + resolver, sshd, )
* leap_slow:    site_config::slow (slow: apt-get update, apt-get dist-upgrade)
* leap_service: cofigure platform service (openvpn, couchdb, etc.)

You can pass any combination of tags, i.e. use

* "--tags leap_base,leap_slow,leap_service" (DEFAULT): Deploy all
* "--tags leap_service": Only deploy service(s) (useful for debugging/development)
* "--tags leap_base": Only deploy basic configuration (again, useful for debugging/development)


### Doing faster partial deploys

If you only change a tiny bit on the platform puppet recipes, you could achieve a
*much* faster deploy specifying the resource tag you changed.
i.e. you changed the way rsyslog config snippets for LEAP logfiles are created
in `puppet/modules/leap/manifests/logfile.pp`. This `define` resource will get tagged
automatically with `leap::logfile` and you can deploy the change with:

    leap deploy *NODE* --fast --tags=leap::logfile

or, if you just want

    leap deploy --tags=dist_upgrade

See http://docs.puppetlabs.com/puppet/2.7/reference/lang_tags.html for puppet tag usage.

