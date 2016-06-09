class shorewall::rules::smtp_submission {
    shorewall::rule { 'net-me-smtp_submission-tcp':
        source          => 'net',
        destination     => '$FW',
        proto           => 'tcp',
        destinationport => '587',
        order           => 240,
        action          => 'ACCEPT';
    }
}
