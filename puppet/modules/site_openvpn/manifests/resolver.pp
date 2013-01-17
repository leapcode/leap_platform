class site_openvpn::resolver {

  # this is an unfortunate way to get around the fact that the version of
  # unbound we are working with does not accept a wildcard include directive
  # (/etc/unbound/conf.d/*), when it does, these line definitions should
  # go away and instead the caching_resolver should be configured to
  # include: /etc/unbound/conf.d/*

  line {
    'add_tcp_resolver':
      ensure => present,
      file   => '/etc/unbound/unbound.conf',
      line   => 'server: include: /etc/unbound/conf.d/vpn_tcp_resolver',
      notify => Service['unbound'];

    'add_udp_resolver':
      ensure => present,
      file   => '/etc/unbound/unbound.conf',
      line   => 'server: include: /etc/unbound/conf.d/vpn_udp_resolver',
      notify => Service['unbound'];
  }

  file {
    '/etc/unbound/conf.d/vpn_udp_resolver':
      content => "interface: ${site_openvpn::openvpn_udp_network_prefix}.1\naccess-control: ${site_openvpn::openvpn_udp_network_prefix}.0/${site_openvpn::openvpn_udp_netmask} allow\n",
      owner => root, group => root, mode => '0644',
      require => Service['openvpn'];

    '/etc/unbound/conf.d/vpn_tcp_resolver':
      content => "interface: ${site_openvpn::openvpn_tcp_network_prefix}.1\naccess-control: ${site_openvpn::openvpn_tcp_network_prefix}.0/${site_openvpn::openvpn_tcp_netmask} allow\n",
      owner => root, group => root, mode => '0644',
      require => Service['openvpn'];
  }
}
