# manage outgoing traffic to managesieve
class shorewall::rules::out::managesieve(
  $legacy_port = false
) {
  shorewall::rule {
    'me-net-tcp_managesieve':
      source          =>      '$FW',
      destination     =>      'net',
      proto           =>      'tcp',
      destinationport =>      '4190',
      order           =>      260,
      action          =>      'ACCEPT';
  }
  if $legacy_port {
    shorewall::rule {
      'me-net-tcp_managesieve_legacy':
        source          =>      '$FW',
        destination     =>      'net',
        proto           =>      'tcp',
        destinationport =>      '2000',
        order           =>      260,
        action          =>      'ACCEPT';
    }
  }
}
