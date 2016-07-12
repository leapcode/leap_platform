class shorewall::rules::out::whois {
    # open whois tcp port 
    shorewall::rule {'me-net-tcp_whois':
        source          => '$FW',
        destination     => 'net',
        proto           => 'tcp',
        destinationport => '43',
        order           => 251,
        action          => 'ACCEPT';
    }
}
