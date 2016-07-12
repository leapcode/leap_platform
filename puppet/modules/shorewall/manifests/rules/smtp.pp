class shorewall::rules::smtp {
    shorewall::rule { 'net-me-smtp-tcp':
        source          => 'net',
        destination     => '$FW',
        proto           => 'tcp',
        destinationport => '25',
        order           => 240,
        action          => 'ACCEPT';
    }
}
