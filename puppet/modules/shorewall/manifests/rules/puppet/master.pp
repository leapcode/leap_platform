class shorewall::rules::puppet::master {
  shorewall::rule { 'net-me-tcp_puppet-main':
    source          => 'net',
    destination     => '$FW',
    proto           => 'tcp',
    destinationport => '$PUPPETSERVER_PORT,$PUPPETSERVER_SIGN_PORT',
    order           => 240,
    action          => 'ACCEPT';
  }
}
