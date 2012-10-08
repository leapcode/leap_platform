class site_shorewall::defaults {
  include shorewall

  # If you want logging:
  shorewall::params {
    'LOG': value => 'debug';
  }

  shorewall::zone {'net': type => 'ipv4'; }

  shorewall::rule_section { 'NEW': order => 10; }

  shorewall::interface {'eth0':
    zone      => 'net',
    options   => 'tcpflags,blacklist,nosmurfs';
  }
}
