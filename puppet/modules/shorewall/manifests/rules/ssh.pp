class shorewall::rules::ssh(
  $ports,
  $source = 'net'
) {
  shorewall::rule { 'net-me-tcp_ssh':
    source          => $shorewall::rules::ssh::source,
    destination     => '$FW',
    proto           => 'tcp',
    destinationport => join($shorewall::rules::ssh::ports,','),
    order           => 240,
    action          => 'ACCEPT';
  }
}
