class shorewall::rules::out::mysql {
    shorewall::rule {
        'me-net-tcp_mysql':
            source          =>  '$FW',
            destination     =>  'net',
            proto           =>  'tcp',
            destinationport =>  '3306',
            order           =>  240,
            action          => 'ACCEPT';
    }
}
