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

  package { 'shorewall-init':
    ensure => installed
  }

  augeas {
    # stop instead of clear firewall on shutdown
    'shorewall_SAFESTOP':
      changes => 'set /files/etc/shorewall/shorewall.conf/SAFESTOP Yes',
      lens    => 'Shellvars.lns',
      incl    => '/etc/shorewall/shorewall.conf',
      require => Package['shorewall'],
      notify  => Service[shorewall];
    # require that the interface exist
    'shorewall_REQUIRE_INTERFACE':
      changes => 'set /files/etc/shorewall/shorewall.conf/REQUIRE_INTERFACE Yes',
      lens    => 'Shellvars.lns',
      incl    => '/etc/shorewall/shorewall.conf',
      require => Package['shorewall'],
      notify  => Service[shorewall];
    # configure shorewall-init
    'shorewall-init':
      changes => 'set /files/etc/default/shorewall-init/PRODUCTS shorewall',
      lens    => 'Shellvars.lns',
      incl    => '/etc/default/shorewall-init',
      require => [ Package['shorewall-init'], Service['shorewall'] ]
  }

  include site_shorewall::sshd
}
