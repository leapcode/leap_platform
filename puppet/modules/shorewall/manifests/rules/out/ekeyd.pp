define shorewall::rules::out::ekeyd($host) {
  shorewall::rule { "me-${name}-tcp_ekeyd":
    source          => '$FW',
    destination     => "${name}:${host}",
    proto           => 'tcp',
    destinationport => '8888',
    order           => 240,
    action          => 'ACCEPT';
  }
}
