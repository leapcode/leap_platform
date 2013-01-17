class site_shorewall::defaults {
  include shorewall

  # If you want logging:
  shorewall::params {
    'LOG': value => 'debug';
  }

  shorewall::zone {'net': type => 'ipv4'; }

  include augeas

  augeas { 'enable_ip_forwarding':
    changes => 'set /files/etc/shorewall/shorewall.conf/IP_FORWARDING Yes',
    lens    => 'Shellvars.lns',
    incl    => '/etc/shorewall/shorewall.conf',
    notify  => Service[shorewall],
    require => Class[augeas];
  }

}
