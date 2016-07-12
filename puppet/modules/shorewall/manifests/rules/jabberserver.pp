# open ports used by a jabberserver
# in and outbound.
class shorewall::rules::jabberserver(
  $open_stun = true,
) {
  shorewall::rule {
    'net-me-tcp_jabber':
        source          => 'net',
        destination     => '$FW',
        proto           => 'tcp',
        destinationport => '5222,5223,5269',
        order           => 240,
        action          => 'ACCEPT';
    'me-net-tcp_jabber_s2s':
        source          => '$FW',
        destination     => 'net',
        proto           => 'tcp',
        destinationport => '5260,5269,5270,5271,5272',
        order           => 240,
        action          => 'ACCEPT';
  }

  if $open_stun {
    shorewall::rule {
      'net-me-udp_jabber_stun_server':
        source          => 'net',
        destination     => '$FW',
        proto           => 'udp',
        destinationport => '3478',
        order           => 240,
        action          => 'ACCEPT';
    }
  }
}
