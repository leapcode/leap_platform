class shorewall::rules::ntp::client {
    # open ntp udp port to fetch time
    shorewall::rule {'me-net-udp_ntp':
        source          => '$FW',
        destination     => 'net',
        proto           => 'udp',
        destinationport => '123',
        order           => 251,
        action          => 'ACCEPT';
    }
}
