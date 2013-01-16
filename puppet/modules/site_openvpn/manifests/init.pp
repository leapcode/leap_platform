class site_openvpn {
  # parse hiera config
  $ip_address                 = hiera('ip_address')
  $interface                  = hiera('interface')
  #$gateway_address           = hiera('gateway_address')
  $openvpn_config             = hiera('openvpn')
  $openvpn_gateway_address    = $openvpn_config['gateway_address']
  $openvpn_tcp_network_prefix = '10.1.0'
  $openvpn_tcp_netmask        = '255.255.248.0'
  $openvpn_tcp_cidr           = '21'
  $openvpn_udp_network_prefix = '10.2.0'
  $openvpn_udp_netmask        = '255.255.248.0'
  $openvpn_udp_cidr           = '21'
  $x509_config                = hiera('x509')

  # deploy ca + server keys
  include site_openvpn::keys

  # create 2 openvpn config files, one for tcp, one for udp
  site_openvpn::server_config { 'tcp_config':
    port        => '1194',
    proto       => 'tcp',
    local       => $openvpn_gateway_address,
    server      => "$openvpn_tcp_network_prefix.0 $openvpn_tcp_netmask",
    push        => "\"dhcp-option DNS $openvpn_tcp_network_prefix.1\"",
    management  => '127.0.0.1 1000'
  }
  site_openvpn::server_config { 'udp_config':
    port        => '1194',
    proto       => 'udp',
    server      => "$openvpn_udp_network_prefix.0 $openvpn_udp_netmask",
    push        => "\"dhcp-option DNS $openvpn_udp_network_prefix.1\"",
    local       => $openvpn_gateway_address,
    management  => '127.0.0.1 1001'
  }

  # add second IP on given interface
  file { '/usr/local/bin/leap_add_second_ip.sh':
    content => "#!/bin/sh
ip addr show dev $interface | grep -q ${openvpn_gateway_address}/24 || ip addr add ${openvpn_gateway_address}/24 dev $interface
/bin/echo 1 > /proc/sys/net/ipv4/ip_forward
",
    mode    => '0755',
  }

  exec { '/usr/local/bin/leap_add_second_ip.sh':
    subscribe   => File['/usr/local/bin/leap_add_second_ip.sh'],
  }

  cron { 'leap_add_second_ip.sh':
    command => "/usr/local/bin/leap_add_second_ip.sh",
    user    => 'root',
    special => 'reboot',
  }

  # setup the resolver to listen on the vpn IP
  include site_openvpn::resolver

  include site_shorewall::eip

  package {
    'openvpn':
      ensure => installed;
  }
  service {
    'openvpn':
      ensure     => running,
      hasrestart => true,
      hasstatus  => true,
      require    => Exec['concat_/etc/default/openvpn'];
  }

  file {
    '/etc/openvpn':
      ensure  => directory,
      require => Package['openvpn'];
  }

  file {
    '/etc/openvpn/keys':
      ensure  => directory,
      require => Package['openvpn'];
  }

  concat {
    '/etc/default/openvpn':
      owner  => root,
      group  => root,
      mode   => 644,
      warn   => true,
      notify => Service['openvpn'];
  }

  concat::fragment {
    'openvpn.default.header':
      content => template('openvpn/etc-default-openvpn.erb'),
      target  => '/etc/default/openvpn',
      order   => 01;
  }

  concat::fragment {
    "openvpn.default.autostart.${name}":
      content => 'AUTOSTART=all',
      target  => '/etc/default/openvpn',
      order   => 10;
  }
}
