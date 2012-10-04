class site_config::eip {
  include site_openvpn
  include site_openvpn::keys

  #$tor=hiera('tor')
  #notice("Tor enabled: $tor")

  #$openvpn_configs=hiera('openvpn_server_configs')
  #create_resources('site_openvpn::server_config', $openvpn_configs)
 
  site_openvpn::server_config { 'tcp_config':
    port    => '1194',
    proto   => 'tcp',
    local   => $::ipaddress_eth0_1,
    server  => '10.42.0.0 255.255.248.0',
    push    => '"dhcp-option DNS 10.42.0.1"',
  }
  site_openvpn::server_config { 'udp_config':
    port    => '1194',
    proto   => 'udp',
    local   => $::ipaddress_eth0_1,
    server  => '10.43.0.0 255.255.248.0',
    push    => '"dhcp-option DNS 10.43.0.1"',
  }
}
