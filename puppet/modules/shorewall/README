modules/shorewall/manifests/init.pp - manage firewalling with shorewall 3.x

Puppet Module for Shorewall
---------------------------
This module manages the configuration of Shorewall (http://www.shorewall.net/)

Requirements
------------

This module requires the augeas module, you can find that here:
https://labs.riseup.net/code/projects/shared-augeas

Copyright
---------

Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
adapted by immerda project group - admin+puppet(at)immerda.ch
adapted by Puzzle ITC - haerry+puppet(at)puzzle.ch
Copyright (c) 2009 Riseup Networks - micah(shift+2)riseup.net
Copyright (c) 2010 intrigeri - intrigeri(at)boum.org
See LICENSE for the full license granted to you.

Based on the work of ADNET Ghislain <gadnet@aqueos.com> from AQUEOS
at https://reductivelabs.com/trac/puppet/wiki/AqueosShorewall

Merged from:
- git://git.puppet.immerda.ch/module-shorewall.git
- git://labs.riseup.net/module_shorewall

Todo
----
- check if shorewall compiles without errors, otherwise fail !

Configuration
-------------

If you need to install a specific version of shorewall other than
the default one that would be installed by 'ensure => present', then
you can set the following variable and that specific version will be
installed instead:

    $shorewall_ensure_version = "4.0.15-1"

The main shorewall.conf is not managed by this module, rather the default one
that your operatingsystem provides is used, and any modifications you wish to do
to it should be configured with augeas, for example, to set IP_FORWARDING=Yes in
shorewall.conf, simply do this:

  augeas { 'enable_ip_forwarding':
    changes => 'set /files/etc/shorewall/shorewall.conf/IP_FORWARDING Yes',
    lens    => 'Shellvars.lns',
    incl    => '/etc/shorewall/shorewall.conf',
    notify  => Service[shorewall];
  }

NOTE: this requires the augeas ruby bindings newer than 0.7.3. 

If you need to, you can provide an entire shorewall.conf by passing its
source to the main class:

class{'shorewall':
  conf_source => "puppet:///modules/site_shorewall/${::fqdn}/shorewall.conf.${::operatingsystem}",
}

NOTE: if you distribute a file, you cannot also use augeas, puppet and augeas
will fight forever. Secondly, you will *need* to make sure that if you are shipping your own
shorewall.conf that you have the following value set in your shorewall.conf otherwise this
module will not work:

    CONFIG_PATH="/etc/shorewall/puppet:/etc/shorewall:/usr/share/shorewall"

Documentation
-------------

see also: http://reductivelabs.com/trac/puppet/wiki/Recipes/AqueosShorewall

Torify
------

The shorewall::rules::torify define can be used to force some outgoing
TCP traffic through the Tor transparent proxy. The corresponding
non-TCP traffic is rejected accordingly.

Beware! This define only is part of a torified setup. DNS requests and
IPv6, amongst others, might leak network activity you would prefer not
to. You really need to read proper documentation about these matters
before using this feature e.g.:

  https://www.torproject.org/download/download.html.en#warning

The Tor transparent proxy location defaults to 127.0.0.1:9040 and can
be configured by setting the $tor_transparent_proxy_host and
$tor_transparent_proxy_port variables before including the main
shorewall class.

Example usage follows.

Torify any outgoing TCP traffic originating from user bob or alice and
aimed at 6.6.6.6 or 7.7.7.7:

  shorewall::rules::torify {
    'torify-some-bits':
      users        => [ 'bob', 'alice' ],
      destinations => [ '6.6.6.6', '7.7.7.7' ];
  }

Torify any outgoing TCP traffic to 8.8.8.8:

  shorewall::rules::torify {
    'torify-to-this-host':
      destinations  => [ '8.8.8.8' ];
  }

When no destination nor user is provided any outgoing TCP traffic (see
restrictions bellow) is torified. In that case the user running the
Tor client ($tor_user) is whitelisted; this variable defaults to
"debian-tor" on Debian systems and to "tor" on others. if this does
not suit your configuration you need to set the $tor_user variable
before including the main shorewall class.

When no destination is provided traffic directed to RFC1918 addresses
is by default allowed and (obviously) not torified. This behaviour can
be changed by setting the allow_rfc1918 parameter to false.

Torify any outgoing TCP traffic but connections to RFC1918 addresses:

  shorewall::rules::torify {
    'torify-everything-but-lan':
  }

Torify any outgoing TCP traffic:

  shorewall::rules::torify {
    'torify-everything:
      allow_rfc1918 => false;
  }

In some cases (e.g. when providing no specific destination nor user
and denying access to RFC1918 addresses) UDP DNS requests may be
rejected. This is intentional: it does not make sense leaking -via DNS
requests- network activity that would otherwise be torified. In that
case you probably want to read proper documentation about such
matters, enable the Tor DNS resolver and redirect DNS requests through
it.

Example
-------

Example from node.pp:

node xy {
	class{'config::site_shorewall':
	  startup => "0"  # create shorewall ruleset but don't startup
  }
	shorewall::rule {
		'incoming-ssh': source => 'all', destination => '$FW',  action  => 'SSH(ACCEPT)', order => 200;
		'incoming-puppetmaster': source => 'all', destination => '$FW',  action  => 'Puppetmaster(ACCEPT)', order => 300;
		'incoming-imap': source => 'all', destination => '$FW',  action  => 'IMAP(ACCEPT)', order => 300;
		'incoming-smtp': source => 'all', destination => '$FW',  action  => 'SMTP(ACCEPT)', order => 300;
	}
}


class config::site_shorewall($startup = '1') {
  class{'shorewall':
    startup => $startup
  }

  # If you want logging:
  #shorewall::params {
  # 'LOG':  value => 'debug';
  #}

  shorewall::zone {'net':
    type => 'ipv4';
  }

  shorewall::rule_section { 'NEW':
    order => 100;
  }

  shorewall::interface { 'eth0':
    zone    => 'net',
    rfc1918  => true,
    options => 'tcpflags,blacklist,nosmurfs';
  }

  shorewall::policy {
    'fw-to-fw':
      sourcezone              =>      '$FW',
      destinationzone         =>      '$FW',
      policy                  =>      'ACCEPT',
      order                   =>      100;
    'fw-to-net':
      sourcezone              =>      '$FW',
      destinationzone         =>      'net',
      policy                  =>      'ACCEPT',
      shloglevel              =>      '$LOG',
      order                   =>      110;
    'net-to-fw':
      sourcezone              =>      'net',
      destinationzone         =>      '$FW',
      policy                  =>      'DROP',
      shloglevel              =>      '$LOG',
      order                   =>      120;
  }       

        
  # default Rules : ICMP 
  shorewall::rule {
    'allicmp-to-host':
      source => 'all',
      destination => '$FW',
      order  => 200,
      action  => 'AllowICMPs/(ACCEPT)';
  }
}


