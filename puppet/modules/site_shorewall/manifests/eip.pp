class site_shorewall::eip {

  include site_shorewall::defaults
  include site_shorewall::ip_forward

  $openvpn_config = hiera('openvpn')
  $openvpn_ports  = $openvpn_config['ports']
  $openvpn_gateway_address = $site_openvpn::openvpn_gateway_address

  # define macro for incoming services
  file { '/etc/shorewall/macro.leap_eip':
    content => "PARAM   -       -       tcp     1194
PARAM   -       -       udp     1194
",
    notify  => Service['shorewall']
  }


  shorewall::interface {
    'tun0':
      zone    => 'eip',
      options => 'tcpflags,blacklist,nosmurfs';
    'tun1':
      zone    => 'eip',
      options => 'tcpflags,blacklist,nosmurfs'
  }


  shorewall::zone {'eip':
    type => 'ipv4'; }

  case $::virtual {
    'virtualbox': {
      shorewall::masq {
        'eth0_tcp':
          interface => 'eth0',
          source    => "${site_openvpn::openvpn_tcp_network_prefix}.0/${site_openvpn::openvpn_tcp_cidr}";
        'eth0_udp':
          interface => 'eth0',
          source    => "${site_openvpn::openvpn_udp_network_prefix}.0/${site_openvpn::openvpn_udp_cidr}"; }
    }
    default: {
      $interface = $site_shorewall::defaults::interface
      shorewall::masq {
        "${interface}_tcp":
          interface => $interface,
          source    => "${site_openvpn::openvpn_tcp_network_prefix}.0/${site_openvpn::openvpn_tcp_cidr}";

        "${interface}_udp":
          interface => $interface,
          source    => "${site_openvpn::openvpn_udp_network_prefix}.0/${site_openvpn::openvpn_udp_cidr}"; }
    }
  }

  shorewall::policy {
    'eip-to-all':
      sourcezone      => 'eip',
      destinationzone => 'all',
      policy          => 'ACCEPT',
      order           => 100;
  }

  shorewall::rule {
      'net2fw-openvpn':
        source      => 'net',
        destination => '$FW',
        action      => 'leap_eip(ACCEPT)',
        order       => 200;
  }

  # create dnat rule for each port
  #create_resources('site_shorewall::dnat_rule', $openvpn_ports)
  site_shorewall::dnat_rule { $openvpn_ports: }

}
