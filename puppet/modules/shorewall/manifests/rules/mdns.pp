class shorewall::rules::mdns {
    shorewall::rule { 'net-me-mdns':
        source          => 'net',
        destination     => '$FW',
        order           => 240,
        action          => 'mDNS(ACCEPT)';
    }
}
