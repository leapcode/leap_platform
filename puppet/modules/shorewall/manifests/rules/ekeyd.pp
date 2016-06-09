class shorewall::rules::ekeyd {
  shorewall::rule { 'net-me-tcp_ekeyd':
    source          => 'net',
    destination     => '$FW',
    proto           => 'tcp',
    destinationport => '8888',
    order           => 240,
    action          => 'ACCEPT';
  }
}
