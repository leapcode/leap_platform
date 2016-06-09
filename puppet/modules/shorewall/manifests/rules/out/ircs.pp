class shorewall::rules::out::ircs {
    shorewall::rule{'me-net-ircs-tcp':
        source          => '$FW',
        destination     => 'net',
        proto           => 'tcp',
        destinationport => '6669',
        order           => 240,
        action          => 'ACCEPT';
    }
}
