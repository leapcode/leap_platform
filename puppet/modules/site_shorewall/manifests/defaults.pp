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

      # server to outside
      'fw2all-http':
        source      => '$FW',
        destination => 'all',
        action      => 'HTTP(ACCEPT)',
        order       => 200;
      'fw2all-DNS':
        source      => '$FW',
        destination => 'all',
        action      => 'DNS(ACCEPT)',
        order       => 200;
      'fw2all-git':
        source      => '$FW',
        destination => 'all',
        action      => 'Git(ACCEPT)',
        order       => 200;
  }

  include site_shorewall::sshd
}
