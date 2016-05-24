class shorewall::rules::mysql {
	shorewall::rule {
		'net-me-tcp_mysql':
            source          => 'net',
            destination     => '$FW',
            proto           => 'tcp',
            destinationport => '3306',
            order           => 240,
            action          => 'ACCEPT';
	}
}
