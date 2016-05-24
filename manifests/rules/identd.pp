class shorewall::rules::identd {
  shorewall::rule { 'net-me-identd-tcp':
    source          => 'net',
    destination     => '$FW',
    proto           => 'tcp',
    destinationport => '113',
    order           => 240,
    action          => 'ACCEPT';
  }
}
