class shorewall::rules::jetty::ssl {
    shorewall::rule {
        'net-me-jettyssl-tcp':
            source          => 'net',
            destination     => '$FW',
            proto           => 'tcp',
            destinationport => '8443',
            order           => 240,
            action          => 'ACCEPT';
    }
}
