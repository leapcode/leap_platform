class site_openvpn::resolver {

  file { '/etc/unbound/conf.d/vpn_resolver':
    content => "interface: $openvpn_gateway_address\n",
    owner => root, group => root, mode => '0644',
    require => Exec['/usr/local/bin/leap_add_second_ip.sh'];
  }
}
