class site_shorewall::defaults {
  include shorewall

  # be safe for development
  #if ( $::virtual == 'virtualbox') { $shorewall_startup='0' }

  $ip_address     = hiera('ip_address')
  # a special case for vagrant interfaces
  $interface      = $::virtual ? {
    virtualbox => [ 'eth0', 'eth1' ],
    default    => getvar("interface_${ip_address}")
  }


  # If you want logging:
  shorewall::params {
    'LOG': value => 'debug';
  }

  shorewall::zone {'net': type => 'ipv4'; }


  # define interfaces
  shorewall::interface { $interface:
    zone      => 'net',
    options   => 'tcpflags,blacklist,nosmurfs';
  }

  shorewall::routestopped { $interface: }

  shorewall::policy {
    'fw-to-all':
      sourcezone      => 'fw',
      destinationzone => 'all',
      policy          => 'ACCEPT',
      order           => 100;
    'all-to-all':
      sourcezone      => 'all',
      destinationzone => 'all',
      policy          => 'DROP',
      order           => 200;
  }

  shorewall::rule {
      # ping party
      'all2all-ping':
        source      => 'all',
        destination => 'all',
        action      => 'Ping(ACCEPT)',
        order       => 200;
  }

  include site_shorewall::sshd
}
