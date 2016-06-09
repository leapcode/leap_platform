class shorewall::rules::managesieve {
    shorewall::rule {
        'net-me-tcp_managesieve':
            source          =>      'net',
            destination     =>      '$FW',
            proto           =>      'tcp',
            destinationport =>      '2000',
            order           =>      260,
            action          =>      'ACCEPT';
    }
}
