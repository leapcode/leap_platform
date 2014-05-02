class site_shorewall::eip {

  include site_shorewall::defaults
  include site_config::params
  include site_shorewall::ip_forward

  # define macro for incoming services
  file { '/etc/shorewall/macro.leap_eip':
    content => "PARAM   -       -       tcp     1194
    PARAM   -       -       udp     1194
    ",
    notify  => Service['shorewall'],
    require => Package['shorewall']
  }

  shorewall::interface {
    'tun0':
      zone    => 'eip',
      options => 'tcpflags,blacklist,nosmurfs';
    'tun1':
      zone    => 'eip',
      options => 'tcpflags,blacklist,nosmurfs';
    'tun2':
      zone    => 'eip',
      options => 'tcpflags,blacklist,nosmurfs';
    'tun3':
      zone    => 'eip',
      options => 'tcpflags,blacklist,nosmurfs';
  }

  shorewall::zone {
    'eip':
      type => 'ipv4';
  }

  $interface = $site_config::params::interface

  shorewall::masq {
    "${interface}_unlimited_tcp":
      interface => $interface,
      source    => "${site_openvpn::openvpn_unlimited_tcp_network_prefix}.0/${site_openvpn::openvpn_unlimited_tcp_cidr}";
    "${interface}_unlimited_udp":
      interface => $interface,
      source    => "${site_openvpn::openvpn_unlimited_udp_network_prefix}.0/${site_openvpn::openvpn_unlimited_udp_cidr}";
  }
  if ! $::ec2_instance_id {
    shorewall::masq {
      "${interface}_limited_tcp":
        interface => $interface,
        source    => "${site_openvpn::openvpn_limited_tcp_network_prefix}.0/${site_openvpn::openvpn_limited_tcp_cidr}";
      "${interface}_limited_udp":
        interface => $interface,
        source    => "${site_openvpn::openvpn_limited_udp_network_prefix}.0/${site_openvpn::openvpn_limited_udp_cidr}";
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

    'block_eip_dns_udp':
      action          => 'REJECT',
      source          => 'eip',
      destination     => 'net',
      proto           => 'udp',
      destinationport => 'domain',
      order           => 300;

    'block_eip_dns_tcp':
      action          => 'REJECT',
      source          => 'eip',
      destination     => 'net',
      proto           => 'tcp',
      destinationport => 'domain',
      order           => 301;
  }

  # create dnat rule for each port
  site_shorewall::dnat_rule { $site_openvpn::openvpn_ports: }

}
