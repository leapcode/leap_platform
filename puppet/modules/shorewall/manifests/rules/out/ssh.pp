class shorewall::rules::out::ssh {
    shorewall::rule { 'me-net-tcp_ssh':
        source          => '$FW',
        destination     => 'net',
        proto           => 'tcp',
        destinationport => 'ssh',
        order           => 240,
        action          => 'ACCEPT';
    }
}
