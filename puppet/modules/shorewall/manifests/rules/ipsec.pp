class shorewall::rules::ipsec(
  $source = 'net'
) {
    shorewall::rule {
      'net-me-ipsec-udp':
        source          => $shorewall::rules::ipsec::source,
        destination     => '$FW',
        proto           => 'udp',
        destinationport => '500',
        order           => 240,
        action          => 'ACCEPT';
      'me-net-ipsec-udp':
        source          => '$FW',
        destination     => $shorewall::rules::ipsec::source,
        proto           => 'udp',
        destinationport => '500',
        order           => 240,
        action          => 'ACCEPT';
      'net-me-ipsec':
        source          => $shorewall::rules::ipsec::source,
        destination     => '$FW',
        proto           => 'esp',
        order           => 240,
        action          => 'ACCEPT';
      'me-net-ipsec':
        source          => '$FW',
        destination     => $shorewall::rules::ipsec::source,
        proto           => 'esp',
        order           => 240,
        action          => 'ACCEPT';
    }
}
