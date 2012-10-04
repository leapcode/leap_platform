class site_config::eip {
  include site_openvpn

  $tor=hiera('tor')
  notice("Tor enabled: $tor")

  #$openvpn_configs=hiera('openvpn_server_configs')
  #create_resources('site_openvpn::server_config', $openvpn_configs)
  
  site_openvpn::server_config { 'tcp_config':
    port => '1194',
    proto => 'tcp'
  }
  site_openvpn::server_config { 'udp_config':
    port => '1194',
    proto => 'udp'
  }
}
