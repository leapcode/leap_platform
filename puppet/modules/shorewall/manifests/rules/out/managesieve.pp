class shorewall::rules::out::managesieve {
    shorewall::rule {
        'me-net-tcp_managesieve':
            source          =>      '$FW',
            destination     =>      'net',
            proto           =>      'tcp',
            destinationport =>      '2000',
            order           =>      260,
            action          =>      'ACCEPT';
    }
}
