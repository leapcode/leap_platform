class site_config::eip {
  include site_openvpn
  include site_openvpn::keys

  $ip_address               = hiera('ip_address')
  $interface                = hiera('interface')
  $gateway_address          = hiera('gateway_address')
  $openvpn_config           = hiera('openvpn')
  $openvpn_gateway_address  = $openvpn_config['gateway_address']

  site_openvpn::server_config { 'tcp_config':
    port        => '1194',
    proto       => 'tcp',
    local       => $openvpn_gateway_address,
    server      => '10.1.0.0 255.255.248.0',
    push        => '"dhcp-option DNS 10.1.0.1"',
    management  => '127.0.0.1 1000'
  }
  site_openvpn::server_config { 'udp_config':
    port        => '1194',
    proto       => 'udp',
    local       => $openvpn_gateway_address,
    server      => '10.2.0.0 255.255.248.0',
    push        => '"dhcp-option DNS 10.2.0.1"',
    management  => '127.0.0.1 1001'
  }

  file { '/usr/local/bin/leap_add_second_ip.sh':
    content => "#!/bin/sh
ip addr show dev $interface | grep -q ${openvpn_gateway_address}/24 || ip addr add ${openvpn_gateway_address}/24 dev $interface",
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

  include site_shorewall::eip
}
