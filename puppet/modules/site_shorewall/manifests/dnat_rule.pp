define site_shorewall::dnat_rule {

  $port = $name
  if $port != 1194 {
    shorewall::rule {
        "dnat_tcp_port_$port":
          action          => 'DNAT',
          source          => 'net',
          destination     => "\$FW:${site_config::eip::openvpn_gateway_address}:1194",
          proto           => 'tcp',
          destinationport => $port,
          order           => 100;
    }

    shorewall::rule {
        "dnat_udp_port_$port":
          action          => 'DNAT',
          source          => 'net',
          destination     => "\$FW:${site_config::eip::openvpn_gateway_address}:1194",
          proto           => 'udp',
          destinationport => $port,
          order           => 100;
    }
  }
}
