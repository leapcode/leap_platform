class shorewall::rules::out::smtp {
    shorewall::rule {
        'me-net-tcp_smtp':
            source          =>  '$FW',
            destination     =>  'net',
            proto           =>  'tcp',
            destinationport =>  'smtp',
            order           =>  240,
            action          => 'ACCEPT';
    }
}
