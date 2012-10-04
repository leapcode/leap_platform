class site_config::eip {
  include site_openvpn

  $tor=hiera('tor')
  notice("Tor enabled: $tor")

  $openvpn_configs=hiera('openvpn_server_configs')
  create_resources('site_openvpn::server_config', $openvpn_configs)

}
