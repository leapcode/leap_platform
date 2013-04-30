class site_shorewall::defaults {
  include shorewall
  include site_config::params

  # be safe for development
  #if ( $::virtual == 'virtualbox') { $shorewall_startup='0' }

  # If you want logging:
  shorewall::params {
    'LOG': value => 'debug';
  }

  shorewall::zone {'net': type => 'ipv4'; }

  # define interfaces
  shorewall::interface { $site_config::params::interface:
    zone      => 'net',
    options   => 'tcpflags,blacklist,nosmurfs';
  }

  shorewall::routestopped { $site_config::params::interface: }

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
