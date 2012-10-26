class site_config::eip {
  include site_openvpn
  include site_openvpn::keys

  #$tor=hiera('tor')
  #notice("Tor enabled: $tor")

  $ip_address               = hiera('ip_address')
  $interface                = hiera('interface')
  $gateway_address          = hiera('gateway_address')
  $openvpn_config           = hiera('openvpn')
  $openvpn_gateway_address  = $openvpn_config['gateway_address']

  include interfaces
  interfaces::iface { $interface:
    family        => 'inet',
    method        => 'static',
    options       => [ "address $ip_address",
      'netmask 255.255.255.0',
      "gateway $gateway_address",
      "up   ip addr add $openvpn_gateway_address/24 dev eth0",
      "down ip addr del $openvpn_gateway_address/24 dev eth0",
      ],
    auto          => 1,
    allow_hotplug => 1 }


  site_openvpn::server_config { 'tcp_config':
    port        => '1194',
    proto       => 'tcp',
    local       => $gateway_address,
    server      => '10.1.0.0 255.255.248.0',
    push        => '"dhcp-option DNS 10.1.0.1"',
    management  => '127.0.0.1 1000'
  }
  site_openvpn::server_config { 'udp_config':
    port        => '1194',
    proto       => 'udp',
    local       => $gateway_address,
    server      => '10.2.0.0 255.255.248.0',
    push        => '"dhcp-option DNS 10.2.0.1"',
    management  => '127.0.0.1 1001'
  }

  include site_shorewall::eip
}
