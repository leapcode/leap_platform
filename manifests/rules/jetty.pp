class shorewall::rules::jetty {
    # open jetty port
    shorewall::rule {
        'net-me-jetty-tcp':
            source          => 'net',
            destination     => '$FW',
            proto           => 'tcp',
            destinationport => '8080',
            order           => 240,
            action          => 'ACCEPT';
    }
}
