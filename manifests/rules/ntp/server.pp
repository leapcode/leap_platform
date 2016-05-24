class shorewall::rules::ntp::server {
    shorewall::rule {'net-me-udp_ntp':
        source          => 'net',
        destination     => '$FW',
        proto           => 'udp',
        destinationport => '123',
        order           => 241, 
        action          => 'ACCEPT';
    }
}
