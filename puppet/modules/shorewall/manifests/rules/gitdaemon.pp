class shorewall::rules::gitdaemon {
        shorewall::rule {'net-me-tcp_gitdaemon':
            source          => 'net',
            destination     => '$FW',
            proto           => 'tcp',
            destinationport => '9418',
            order           => 240,
            action          => 'ACCEPT';
        }
}
