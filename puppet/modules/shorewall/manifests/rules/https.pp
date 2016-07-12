class shorewall::rules::https {
    shorewall::rule { 'net-me-https-tcp':
        source          => 'net',
        destination     => '$FW',
        proto           => 'tcp',
        destinationport => '443',
        order           => 240,
        action          => 'ACCEPT';
    }
}
