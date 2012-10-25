class site_config::eip {
  include site_openvpn
  include site_openvpn::keys

  #$tor=hiera('tor')
  #notice("Tor enabled: $tor")

  $openvpn_config     = hiera('openvpn')
  $interface          = hiera('interface')
  $gateway_address    = $openvpn_config['gateway_address']

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
