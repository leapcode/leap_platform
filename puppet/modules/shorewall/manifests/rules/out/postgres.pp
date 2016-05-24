class shorewall::rules::out::postgres {
    shorewall::rule {
        'me-net-tcp_postgres':
            source          =>  '$FW',
            destination     =>  'net',
            proto           =>  'tcp',
            destinationport =>  '5432',
            order           =>  240,
            action          => 'ACCEPT';
    }
}
