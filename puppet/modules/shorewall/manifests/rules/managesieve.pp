# manage managesieve ports
class shorewall::rules::managesieve(
  $legacy_port = false,
) {
  shorewall::rule {
    'net-me-tcp_managesieve':
      source          =>      'net',
      destination     =>      '$FW',
      proto           =>      'tcp',
      destinationport =>      '4190',
      order           =>      260,
      action          =>      'ACCEPT';
  }
  if $legacy_port {
    shorewall::rule {
      'net-me-tcp_managesieve_legacy':
        source          =>      'net',
        destination     =>      '$FW',
        proto           =>      'tcp',
        destinationport =>      '2000',
        order           =>      260,
        action          =>      'ACCEPT';
    }
  }
}
