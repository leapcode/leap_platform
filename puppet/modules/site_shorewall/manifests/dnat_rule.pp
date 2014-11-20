define site_shorewall::dnat_rule {

  $port = $name
  if $port != 1194 {
    if $site_openvpn::openvpn_allow_unlimited {
      shorewall::rule {
          "dnat_tcp_port_${port}":
            action          => 'DNAT',
            source          => 'net',
            destination     => "\$FW:${site_openvpn::unlimited_gateway_address}:1194",
            proto           => 'tcp',
            destinationport => $port,
            order           => 100;
      }
      shorewall::rule {
          "dnat_udp_port_${port}":
            action          => 'DNAT',
            source          => 'net',
            destination     => "\$FW:${site_openvpn::unlimited_gateway_address}:1194",
            proto           => 'udp',
            destinationport => $port,
            order           => 100;
      }
    }
    if $site_openvpn::openvpn_allow_limited {
      shorewall::rule {
          "dnat_free_tcp_port_${port}":
            action          => 'DNAT',
            source          => 'net',
            destination     => "\$FW:${site_openvpn::limited_gateway_address}:1194",
            proto           => 'tcp',
            destinationport => $port,
            order           => 100;
      }
      shorewall::rule {
          "dnat_free_udp_port_${port}":
            action          => 'DNAT',
            source          => 'net',
            destination     => "\$FW:${site_openvpn::limited_gateway_address}:1194",
            proto           => 'udp',
            destinationport => $port,
            order           => 100;
      }
    }
  }
}
