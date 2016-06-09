class shorewall::rules::out::irc {
    shorewall::rule{'me-net-irc-tcp':
        source          => '$FW',
        destination     => 'net',
        proto           => 'tcp',
        destinationport => '6667',
        order           => 240,
        action          => 'ACCEPT';
    }
}
