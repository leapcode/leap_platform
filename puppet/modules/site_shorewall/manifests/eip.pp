class site_shorewall::eip {

  # be safe for development
  if ( $::virtual == 'virtualbox') { $shorewall_startup='0' }

  include site_shorewall::defaults

  $ip_address     = hiera('ip_address')
  # a special case for vagrant interfaces
  $interface      = $::virtual ? {
    virtualbox => [ 'eth0', 'eth1' ],
    default    => getvar("${ip_address}_interface")
  }
  $ssh_config     = hiera('ssh')
  $ssh_port       = $ssh_config['port']
  $openvpn_config = hiera('openvpn')
  $openvpn_ports  = $openvpn_config['ports']
  $openvpn_gateway_address = $site_openvpn::openvpn_gateway_address

  # define macro for incoming services
  file { '/etc/shorewall/macro.leap_eip':
    content => "PARAM   -       -       tcp     1194,$ssh_port
PARAM   -       -       udp     1194
", }


  # define interfaces
  shorewall::interface { $interface:
    zone      => 'net',
    options   => 'tcpflags,blacklist,nosmurfs';
  }

  shorewall::interface {
    'tun0':
      zone    => 'eip',
      options => 'tcpflags,blacklist,nosmurfs';
    'tun1':
      zone    => 'eip',
      options => 'tcpflags,blacklist,nosmurfs'
  }


  shorewall::zone         {'eip':
    type => 'ipv4'; }

  shorewall::routestopped { $interface: }

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
    'fw-to-all':
      sourcezone      => '$FW',
      destinationzone => 'all',
      policy          => 'ACCEPT',
      order           => 100;
    'all-to-all':
      sourcezone      => 'all',
      destinationzone => 'all',
      policy          => 'DROP',
      order           => 200;
  }

  shorewall::rule {
      # ping party
      'all2all-ping':
        source      => 'all',
        destination => 'all',
        action      => 'Ping(ACCEPT)',
        order       => 200;

      # outside to server
      'net2fw-ssh':
        source      => 'net',
        destination => '$FW',
        action      => 'SSH(ACCEPT)',
        order       => 200;
      'net2fw-openvpn':
        source      => 'net',
        destination => '$FW',
        action      => 'leap_eip(ACCEPT)',
        order       => 200;

      # server to outside
      'fw2all-http':
        source      => '$FW',
        destination => 'all',
        action      => 'HTTP(ACCEPT)',
        order       => 200;
      'fw2all-DNS':
        source      => '$FW',
        destination => 'all',
        action      => 'DNS(ACCEPT)',
        order       => 200;
      'fw2all-git':
        source      => '$FW',
        destination => 'all',
        action      => 'Git(ACCEPT)',
        order       => 200;

      # Webfrontend is running on another server
      #'eip2fw-https':
      #  source      => 'eip',
      #  destination => '$FW',
      #  action      => 'HTTPS(ACCEPT)',
      #  order       => 200;
  }

  # create dnat rule for each port
  #create_resources('site_shorewall::dnat_rule', $openvpn_ports)
  site_shorewall::dnat_rule { $openvpn_ports: }

}
