#
# An openvpn gateway can support three modes:
#
#   (1) limited and unlimited
#   (2) unlimited only
#   (3) limited only
#
# The difference is that 'unlimited' gateways only allow client certs that match the 'unlimited_prefix',
# and 'limited' gateways only allow certs that match the 'limited_prefix'.
#
# We potentially create four openvpn config files (thus four daemons):
#
#   (1) unlimited + tcp => tcp_config.conf
#   (2) unlimited + udp => udp_config.conf
#   (3) limited + tcp => limited_tcp_config.conf
#   (4) limited + udp => limited_udp_config.conf
#

class site_openvpn {
  tag 'leap_service'

  $openvpn_config   = hiera('openvpn')
  $x509_config      = hiera('x509')
  $openvpn_ports    = $openvpn_config['ports']
  $openvpn_gateway_address         = $openvpn_config['gateway_address']
  if $openvpn_config['second_gateway_address'] {
    $openvpn_second_gateway_address = $openvpn_config['second_gateway_address']
  } else {
    $openvpn_second_gateway_address = undef
  }

  $openvpn_allow_unlimited              = $openvpn_config['allow_unlimited']
  $openvpn_unlimited_prefix             = $openvpn_config['unlimited_prefix']
  $openvpn_unlimited_tcp_network_prefix = '10.41.0'
  $openvpn_unlimited_tcp_netmask        = '255.255.248.0'
  $openvpn_unlimited_tcp_cidr           = '21'
  $openvpn_unlimited_udp_network_prefix = '10.42.0'
  $openvpn_unlimited_udp_netmask        = '255.255.248.0'
  $openvpn_unlimited_udp_cidr           = '21'

  $openvpn_allow_limited                = $openvpn_config['allow_limited']
  $openvpn_limited_prefix               = $openvpn_config['limited_prefix']
  $openvpn_rate_limit                   = $openvpn_config['rate_limit']
  $openvpn_limited_tcp_network_prefix   = '10.43.0'
  $openvpn_limited_tcp_netmask          = '255.255.248.0'
  $openvpn_limited_tcp_cidr             = '21'
  $openvpn_limited_udp_network_prefix   = '10.44.0'
  $openvpn_limited_udp_netmask          = '255.255.248.0'
  $openvpn_limited_udp_cidr             = '21'

  # deploy ca + server keys
  include site_openvpn::keys

  if $openvpn_allow_unlimited and $openvpn_allow_limited {
    $unlimited_gateway_address = $openvpn_gateway_address
    $limited_gateway_address = $openvpn_second_gateway_address
  } elsif $openvpn_allow_unlimited {
    $unlimited_gateway_address = $openvpn_gateway_address
    $limited_gateway_address = undef
  } elsif $openvpn_allow_limited {
    $unlimited_gateway_address = undef
    $limited_gateway_address = $openvpn_gateway_address
  }

  if $openvpn_allow_unlimited {
    site_openvpn::server_config { 'tcp_config':
      port        => '1194',
      proto       => 'tcp',
      local       => $unlimited_gateway_address,
      tls_remote  => "\"${openvpn_unlimited_prefix}\"",
      server      => "${openvpn_unlimited_tcp_network_prefix}.0 ${openvpn_unlimited_tcp_netmask}",
      push        => "\"dhcp-option DNS ${openvpn_unlimited_tcp_network_prefix}.1\"",
      management  => '127.0.0.1 1000'
    }
    site_openvpn::server_config { 'udp_config':
      port        => '1194',
      proto       => 'udp',
      local       => $unlimited_gateway_address,
      tls_remote  => "\"${openvpn_unlimited_prefix}\"",
      server      => "${openvpn_unlimited_udp_network_prefix}.0 ${openvpn_unlimited_udp_netmask}",
      push        => "\"dhcp-option DNS ${openvpn_unlimited_udp_network_prefix}.1\"",
      management  => '127.0.0.1 1001'
    }
  } else {
    tidy { "/etc/openvpn/tcp_config.conf": }
    tidy { "/etc/openvpn/udp_config.conf": }
  }

  if $openvpn_allow_limited {
    site_openvpn::server_config { 'limited_tcp_config':
      port        => '1194',
      proto       => 'tcp',
      local       => $limited_gateway_address,
      tls_remote  => "\"${openvpn_limited_prefix}\"",
      server      => "${openvpn_limited_tcp_network_prefix}.0 ${openvpn_limited_tcp_netmask}",
      push        => "\"dhcp-option DNS ${openvpn_limited_tcp_network_prefix}.1\"",
      management  => '127.0.0.1 1002'
    }
    site_openvpn::server_config { 'limited_udp_config':
      port        => '1194',
      proto       => 'udp',
      local       => $limited_gateway_address,
      tls_remote  => "\"${openvpn_limited_prefix}\"",
      server      => "${openvpn_limited_udp_network_prefix}.0 ${openvpn_limited_udp_netmask}",
      push        => "\"dhcp-option DNS ${openvpn_limited_udp_network_prefix}.1\"",
      management  => '127.0.0.1 1003'
    }
  } else {
    tidy { "/etc/openvpn/limited_tcp_config.conf": }
    tidy { "/etc/openvpn/limited_udp_config.conf": }
  }

  file {
    '/usr/local/bin/add_gateway_ips.sh':
      content => template('site_openvpn/add_gateway_ips.sh.erb'),
      mode    => '0755';
  }

  exec { '/usr/local/bin/add_gateway_ips.sh':
    subscribe   => File['/usr/local/bin/add_gateway_ips.sh'],
  }

  cron { 'add_gateway_ips.sh':
    command => '/usr/local/bin/add_gateway_ips.sh',
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
