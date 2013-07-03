@title = "Under the hood"

This page contains various details on the how the platform is implemented. You can safely ignore this page, although it may be useful if you plan to make modifications to the platform.

Puppet Details
======================================

Run stages
----------

We use two run stages for resource ordering:

* initial: configure hostname, apt-get update + apt-get dist-upgrade
* main: everything else

Stage initial is run before stage main.

see http://docs.puppetlabs.com/puppet/2.7/reference/lang_run_stages.html for run stage documentation.

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

See http://docs.puppetlabs.com/puppet/2.7/reference/lang_tags.html for puppet tag usage.


