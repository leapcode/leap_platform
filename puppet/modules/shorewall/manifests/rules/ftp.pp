class shorewall::rules::ftp {
    shorewall::rule { 'net-me-ftp-tcp':
        source          => 'net',
        destination     => '$FW',
        proto           => 'tcp',
        destinationport => '21',
        order           => 240,
        action          => 'FTP/ACCEPT';
    }
}
