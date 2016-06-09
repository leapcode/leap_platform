class shorewall::rules::http {
    shorewall::rule { 'net-me-http-tcp':
        source          => 'net',
        destination     => '$FW',
        proto           => 'tcp',
        destinationport => '80',
        order           => 240,
        action          => 'ACCEPT';
    }
}
