class site_openvpn::resolver {

  file {
    '/etc/unbound/conf.d/vpn_udp_resolver':
      content => "interface: ${openvpn_udp_network_prefix}.1\naccess-control: ${openvpn_udp_network_prefix}.0/${openvpn_udp_netmask} allow\n",
      owner => root, group => root, mode => '0644',
      require => Service['openvpn'];

    '/etc/unbound/conf.d/vpn_tcp_resolver':
      content => "interface: ${openvpn_tcp_network_prefix}.1\naccess-control: ${openvpn_tcp_network_prefix}.0/${openvpn_tcp_netmask} allow\n",
      owner => root, group => root, mode => '0644',
      require => Service['openvpn'];
  }
}
