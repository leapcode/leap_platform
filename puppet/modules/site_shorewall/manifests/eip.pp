class site_shorewall::eip {

  # be safe for development
  $shorewall_startup='0'

  include site_shorewall::defaults

  shorewall::interface    {'tun0':
    zone    => 'eip',
    rfc1918 => $shorewall_rfc1918_maineth,
    options => 'tcpflags,blacklist,nosmurfs'; }
  shorewall::interface    {'tun1':
    zone    => 'eip',
    rfc1918 => $shorewall_rfc1918_maineth,
    options => 'tcpflags,blacklist,nosmurfs'; }

  shorewall::zone         {'eip':
    type => 'ipv4'; }

  shorewall::routestopped {'eth0':
    interface => 'eth0'; }

  shorewall::masq {'eth0':
    interface => 'eth0',
    source    => ''; }

  shorewall::policy {
    'all-to-all':
      sourcezone      => 'all',
      destinationzone => 'all',
      policy          => 'DROP',
      order           => 200;
  }

  shorewall::rule {
      'all2all-ping':
        source      => 'all',
        destination => 'all',
        action      => 'Ping(ACCEPT)',
        order       => 200;
      'all2all-ssh':
        source      => 'all',
        destination => 'all',
        action      => 'SSH(ACCEPT)',
        order       => 200;
      'all2all-openvpn':
        source      => 'all',
        destination => 'all',
        action      => 'OpenVPN(ACCEPT)',
        order       => 200;
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
      'eip2fw-https':
        source      => 'eip',
        destination => '$FW',
        action      => 'HTTPS(ACCEPT)',
        order       => 200;
  }
}
