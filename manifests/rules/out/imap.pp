class shorewall::rules::out::imap {
    shorewall::rule {
        'me-net-tcp_imap_s':
            source          =>      '$FW',
            destination     =>      'net',
            proto           =>      'tcp',
            destinationport =>      '143,993',
            order           =>      260,
            action          =>      'ACCEPT';
    }
}
