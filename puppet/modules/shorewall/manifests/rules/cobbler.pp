class shorewall::rules::cobbler {
     shorewall::rule{'net-me-syslog-xmlrpc-tcp':
        source          => 'net',
        destination     => '$FW',
        proto           => 'tcp',
        destinationport => '25150:25151',
        order           => 240,
        action          => 'ACCEPT';
    }
    shorewall::rule{'net-me-syslog-xmlrpc-udp':
        source          => 'net',
        destination     => '$FW',
        proto           => 'udp',
        destinationport => '25150:25151',
        order           => 240,
        action          => 'ACCEPT';
    }
    include shorewall::rules::rsync
}
