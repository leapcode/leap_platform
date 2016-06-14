# manage ipsec rules for zone specified in
# $name
define shorewall::rules::ipsec() {
  shorewall::rule {
    "${name}-me-ipsec-udp":
      source          => $name,
      destination     => '$FW',
      proto           => 'udp',
      destinationport => '500',
      order           => 240,
      action          => 'ACCEPT';
    "me-${name}-ipsec-udp":
      source          => '$FW',
      destination     => $name,
      proto           => 'udp',
      destinationport => '500',
      order           => 240,
      action          => 'ACCEPT';
    "${name}-me-ipsec":
      source          => $name,
      destination     => '$FW',
      proto           => 'esp',
      order           => 240,
      action          => 'ACCEPT';
    "me-${name}-ipsec":
      source          => '$FW',
      destination     => $name,
      proto           => 'esp',
      order           => 240,
      action          => 'ACCEPT';
  }
}
