# open dns port
define shorewall::rules::dns_rules(
  $source = $name,
  $action = 'ACCEPT',
) {
  shorewall::rule {
    "${source}-me-tcp_dns":
      source          => $source,
      destination     => '$FW',
      proto           => 'tcp',
      destinationport => '53',
      order           => 240,
      action          => $action;
    "${source}-me-udp_dns":
      source          => $source,
      destination     => '$FW',
      proto           => 'udp',
      destinationport => '53',
      order           => 240,
      action          => $action;
  }
}
