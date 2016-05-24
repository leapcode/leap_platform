class shorewall::rules::postgres {
    shorewall::rule { 'net-me-tcp_postgres':
        source          => 'net',
        destination     => '$FW',
        proto           => 'tcp',
        destinationport => '5432',
        order           => 250,
        action          => 'ACCEPT';
    }
}
