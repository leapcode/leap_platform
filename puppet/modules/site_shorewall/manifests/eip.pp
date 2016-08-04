# Configure shorewall on eip/vpn nodes
class site_shorewall::eip {

  include site_shorewall::defaults
  include site_config::params
  include site_shorewall::ip_forward

  # define macro for incoming services
  file { '/etc/shorewall/macro.leap_eip':
    content => "PARAM   -       -       tcp     1194
    PARAM   -       -       udp     1194
    ",
    notify  => Exec['shorewall_check'],
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

    'accept_all_eip_to_eip_gateway_udp_unlimited':
      action          => 'ACCEPT',
      source          => 'eip',
      destination     => 'eip:10.41.0.1',
      proto           => 'all',
      order           => 302;

    'accept_all_eip_to_eip_gateway_tcp_unlimited':
      action          => 'ACCEPT',
      source          => 'eip',
      destination     => 'eip:10.42.0.1',
      proto           => 'all',
      order           => 303;

    'accept_all_eip_to_eip_gateway_udp_limited':
      action          => 'ACCEPT',
      source          => 'eip',
      destination     => 'eip:10.43.0.1',
      proto           => 'all',
      order           => 304;

    'accept_all_eip_to_eip_gateway_tcp_limited':
      action          => 'ACCEPT',
      source          => 'eip',
      destination     => 'eip:10.44.0.1',
      order           => 305;

    'reject_all_other_eip_to_eip':
      action          => 'REJECT',
      source          => 'eip',
      destination     => 'eip',
      order           => 306;
    # Strict egress filtering:
    # SMTP (TCP 25)
    # Trivial File Transfer Protocol - TFTP (UDP 69)
    # MS RPC (TCP & UDP 135)
    # NetBIOS/IP (TCP/UDP 139 & UDP 137, UDP 138)
    # Simple Network Management Protocol – SNMP (UDP/TCP 161-162)
    # SMB/IP (TCP/UDP 445)
    # Syslog (UDP 514)
    # Gamqowi trojan: TCP 4661
    # Mneah trojan: TCP 4666
    'reject_outgoing_smtp':
      action          => 'REJECT',
      source          => 'eip',
      destination     => 'net',
      proto           => 'tcp',
      destinationport => 'smtp',
      order           => 401;
    'reject_outgoing_tftp':
      action          => 'REJECT',
      source          => 'eip',
      destination     => 'net',
      proto           => 'udp',
      destinationport => 'tftp',
      order           => 402;
    'reject_outgoing_ms_rpc_tcp':
      action          => 'REJECT',
      source          => 'eip',
      destination     => 'net',
      proto           => 'tcp',
      destinationport => '135',
      order           => 403;
    'reject_outgoing_ms_rpc_udp':
      action          => 'REJECT',
      source          => 'eip',
      destination     => 'net',
      proto           => 'udp',
      destinationport => '135',
      order           => 404;
    'reject_outgoing_netbios_tcp':
      action          => 'REJECT',
      source          => 'eip',
      destination     => 'net',
      proto           => 'tcp',
      destinationport => '139',
      order           => 405;
    'reject_outgoing_netbios_udp':
      action          => 'REJECT',
      source          => 'eip',
      destination     => 'net',
      proto           => 'tcp',
      destinationport => '139',
      order           => 406;
    'reject_outgoing_netbios_2':
      action          => 'REJECT',
      source          => 'eip',
      destination     => 'net',
      proto           => 'udp',
      destinationport => '137',
      order           => 407;
    'reject_outgoing_netbios_3':
      action          => 'REJECT',
      source          => 'eip',
      destination     => 'net',
      proto           => 'udp',
      destinationport => '138',
      order           => 408;
    'reject_outgoing_snmp_udp':
      action          => 'REJECT',
      source          => 'eip',
      destination     => 'net',
      proto           => 'udp',
      destinationport => 'snmp',
      order           => 409;
    'reject_outgoing_snmp_tcp':
      action          => 'REJECT',
      source          => 'eip',
      destination     => 'net',
      proto           => 'tcp',
      destinationport => 'snmp',
      order           => 410;
    'reject_outgoing_smb_udp':
      action          => 'REJECT',
      source          => 'eip',
      destination     => 'net',
      proto           => 'udp',
      destinationport => '445',
      order           => 411;
    'reject_outgoing_smb_tcp':
      action          => 'REJECT',
      source          => 'eip',
      destination     => 'net',
      proto           => 'tcp',
      destinationport => '445',
      order           => 412;
    'reject_outgoing_syslog':
      action          => 'REJECT',
      source          => 'eip',
      destination     => 'net',
      proto           => 'udp',
      destinationport => 'syslog',
      order           => 413;
    'reject_outgoing_gamqowi':
      action          => 'REJECT',
      source          => 'eip',
      destination     => 'net',
      proto           => 'tcp',
      destinationport => '4661',
      order           => 414;
    'reject_outgoing_mneah':
      action          => 'REJECT',
      source          => 'eip',
      destination     => 'net',
      proto           => 'tcp',
      destinationport => '4666',
      order           => 415;
  }

  # create dnat rule for each port
  site_shorewall::dnat_rule { $site_openvpn::openvpn_ports: }

}
