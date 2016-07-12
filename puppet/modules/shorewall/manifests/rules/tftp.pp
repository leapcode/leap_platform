class shorewall::rules::tftp {
    shorewall::rule { 'net-me-tftp-tcp':
        source          => 'net',
        destination     => '$FW',
        proto           => 'tcp',
        destinationport => '69',
        order           => 240,
        action          => 'ACCEPT';
    }
    shorewall::rule { 'net-me-tftp-udp':
        source          => 'net',
        destination     => '$FW',
        proto           => 'udp',
        destinationport => '69',
        order           => 240,
        action          => 'ACCEPT';
    }
}
