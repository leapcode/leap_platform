Postfix Puppet module
=====================

This module will help install and configure postfix.

A couple of classes will preconfigure postfix for common needs.

This module needs:

- the concat module: git://labs.riseup.net/shared-concat

!! Upgrade Notice (01/2013) !!

This module now uses parameterized classes, where it used global variables
before. So please whatch out before pulling, you need to change the
class declarations in your manifest !

Issues
------

- Debian wheezy hosts (or below): If you get this error msg:

    "Could not find template 'postfix/master.cf.debian-.erb' at /ssrv/leap/puppet/modules/postfix/manifests/init.pp:158 on node rew07plain1.rewire.org"

  you need to use the facter package from wheezy-backports instead of the wheezy one. See https://gitlab.com/shared-puppet-modules-group/postfix/merge_requests/6#note_1892207 for more details.


Deprecation notice
------------------

It used to be that one could drop header checks snippets into the
following source directories:

   "puppet:///modules/site-postfix/${fqdn}/header_checks.d"
   "puppet:///modules/site-postfix/header_checks.d"
   "puppet:///files/etc/postfix/header_checks.d"
   "puppet:///modules/postfix/header_checks.d"

... and TLS policy snippets into those:

   "puppet:///modules/site-postfix/${fqdn}/tls_policy.d"
   "puppet:///modules/site-postfix/tls_policy.d"
   "puppet:///modules/postfix/tls_policy.d"

This is not supported anymore.

Every such snippet much now be configured using the (respectively)
postfix::header_checks_snippet and postfix::tlspolicy_snippet defines.

Note: You will need to set a global Exec { path => '...' } to a proper pathing
in your manifests, or you will experience some issues such as:

err: Failed to apply catalog: Parameter unless failed: 'test "x$(postconf -h relay_domains)" == 'xlocalhost host.foo.com'' is not qualified and no path was specified. Please qualify the command or specify a path.

See: http://www.puppetcookbook.com/posts/set-global-exec-path.html for more
information about how to do this

Postfix class configuration parameters
--------------------------------------

 * use_amavisd => 'yes' - to include postfix::amavis

 * anon_sasl => 'yes' -  to hide the originating IP in email
   relayed for an authenticated SASL client; this needs Postfix
   2.3 or later to work; beware! Postfix logs the header replacement
   has been done, which means that you are storing this information,
   unless you are anonymizing your logs.

 * manage_header_checks => 'yes' - to manage header checks (see
   postfix::header_checks for details)

 * manage_transport_regexp => 'yes' - to manage header checks (see
   postfix::transport_regexp for details)

 * manage_virtual_regexp => 'yes' - to manage header checks (see
   postfix::virtual_regexp for details)

 * manage_tls_policy => 'yes - to manage TLS policy (see
   postfix::tlspolicy for details)

 * inet_interfaces: by default, postfix will bind to all interfaces, but
   sometimes you don't want that. To bind to specific interfaces, use the
   'inet_interfaces' parameter and set it to exactly what would be in the
   main.cf file.

 * myorigin: some hosts have weird-looking host names (dedicated servers and VPSes). To
   set the server's domain of origin, set the 'myorigin' parameter

 * smtp_listen: address on which the smtp service will listen (Default: 127.0.0.1)

 * root_mail_recipient: who will receive root's emails (Default: 'nobody')

 * tls_fingerprint_digest: fingerprint digest for tls policy class (Default: 'sha1')

 * use_dovecot_lda: include dovecot declaration at master.cf

 * use_schleuder: whether to include schleuder portion at master.cf

 * use_sympa: whether to include sympa portion at master.cf

 * use_firma: whether to include firma portion at master.cf

 * use_mlmmj: whether to include mlmmj portion at master.cf

 * use_submission: set to "yes" to enable submission section at master.cf

 * use_smtps: set to "yes" to enable smtps section at master.cf

 * mastercf_tail: set this for additional content to be added at the end of master.cf

== Examples:

  class { 'postfix': }

  class { 'postfix': anon_sasl => 'yes', myorigin => 'foo.bar.tz' }

  postfix::config { "relay_domains": value  => "localhost host.foo.com" }


Convience classes
=================

postfix::config
---------------
this can be used to pass arbitrary postfix configurations by passing the $name
to postconf to add/alter/remove options in main.cf

Parameters:
- *name*: name of the parameter.
- *ensure*: present/absent. defaults to present.
- *value*: value of the parameter.
- *nonstandard*: inform postfix::config that this parameter is not recognized
  by the "postconf" command. defaults to false.

Requires:
- Class["postfix"]

Example usage:

    postfix::config {
      "smtp_use_tls"            => "yes";
      "smtp_sasl_auth_enable"   => "yes";
      "smtp_sasl_password_maps" => "hash:/etc/postfix/my_sasl_passwords";
      "relayhost"               => "[mail.example.com]:587";
    }


postfix::disable
----------------
If you include this class, the postfix package will be removed and the service
stopped.


postfix::hash
-------------
This can be used to create postfix hashed "map" files. It will create "${name}",
and then build "${name}.db" using the "postmap" command. The map file can then
be referred to using postfix::config.

Parameters:
- *name*: the name of the map file.
- *ensure*: present/absent, defaults to present.
- *source*: file source.

Requires:
- Class["postfix"]

Example usage:

    postfix::hash { "/etc/postfix/virtual":
      ensure => present,
    }
    postfix::config { "virtual_alias_maps":
      value => "hash:/etc/postfix/virtual"
    }


postfix::virtual
----------------
Manages content of the /etc/postfix/virtual map

Parameters:
- *name*: name of address postfix will lookup. See virtual(8).
- *destination*: where the emails will be delivered to. See virtual(8).
- *ensure*: present/absent, defaults to present.

Requires:
- Class["postfix"]
- Postfix::Hash["/etc/postfix/virtual"]
- Postfix::Config["virtual_alias_maps"]
- common::line (from module common)

Example usage:

    postfix::hash { "/etc/postfix/virtual":
      ensure => present,
    }
    postfix::config { "virtual_alias_maps":
      value => "hash:/etc/postfix/virtual"
    }
    postfix::virtual { "user@example.com":
      ensure      => present,
      destination => "root",
    }

postfix::mailalias
------------------
Wrapper around Puppet mailalias resource, provides newaliases executable.

Parameters:
- *name*: the name of the alias.
- *ensure*: present/absent, defaults to present.
- *recipient*: recipient of the alias.

Requires:
- Class["postfix"]

Example usage:

    postfix::mailalias { "postmaster":
      ensure => present,
      recipient => 'foo'
    }

