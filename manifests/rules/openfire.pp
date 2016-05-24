class shorewall::rules::openfire {
  include shorewall::rules::jaberserver

  shorewall::rule { 'me-all-openfire-tcp':
    source          => '$FW',
    destination     => 'all',
    proto           => 'tcp',
    destinationport => '7070,7443,7777',
    order           => 240,
    action          => 'ACCEPT';
  }
}
