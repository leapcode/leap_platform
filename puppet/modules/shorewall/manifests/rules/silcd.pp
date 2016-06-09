class shorewall::rules::silcd {
  shorewall::rule{
    'net-me-silcd-tcp':
      source          => 'net',
      destination     => '$FW',
      proto           => 'tcp',
      destinationport => '706',
      order           => 240,
      action          => 'ACCEPT';
    'net-me-silcd-udp':
      source          => 'net',
      destination     => '$FW',
      proto           => 'udp',
      destinationport => '706',
      order           => 240,
      action          => 'ACCEPT';

  }
}
