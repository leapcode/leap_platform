class site_shorewall::defaults {
  include shorewall

  # If you want logging:
  shorewall::params {
    'LOG': value => 'debug';
  }

  shorewall::zone {'net': type => 'ipv4'; }

  shorewall::rule_section { 'NEW': order => 10; }

  case $shorewall_rfc1918_maineth {
    '': {$shorewall_rfc1918_maineth = true }
  }

  case $shorewall_main_interface {
    '': { $shorewall_main_interface = 'eth0' }
  }

  shorewall::interface {$shorewall_main_interface:
    zone      => 'net',
    rfc1918   => $shorewall_rfc1918_maineth,
    options   => 'tcpflags,blacklist,nosmurfs';
  }
}
