class shorewall::rules::ipsec_nat {
    shorewall::rule {
      'net-me-ipsec-nat-udp':
        source          => 'net',
        destination     => '$FW',
        proto           => 'udp',
        destinationport => '4500',
        order           => 240,
        action          => 'ACCEPT';
      'me-net-ipsec-nat-udp':
        source          => '$FW',
        destination     => 'net',
        proto           => 'udp',
        destinationport => '4500',
        order           => 240,
        action          => 'ACCEPT';
    }
}
