#
# An openvpn gateway can support three modes:
#
#   (1) limited and unlimited
#   (2) unlimited only
#   (3) limited only
#
# The difference is that 'unlimited' gateways only allow client certs that match
# the 'unlimited_prefix', and 'limited' gateways only allow certs that match the
# 'limited_prefix'.
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

  include site_config::x509::cert
  include site_config::x509::key
  include site_config::x509::ca_bundle

  include site_config::default
  Class['site_config::default'] -> Class['site_openvpn']

  include ::site_obfsproxy

  $openvpn          = hiera('openvpn')
  $openvpn_ports    = $openvpn['ports']
  $openvpn_config   = $openvpn['configuration']

  if $::ec2_instance_id {
    $openvpn_gateway_address = $::ipaddress
  } else {
    $openvpn_gateway_address         = $openvpn['gateway_address']
    if $openvpn['second_gateway_address'] {
      $openvpn_second_gateway_address = $openvpn['second_gateway_address']
    } else {
      $openvpn_second_gateway_address = undef
    }
  }

  $openvpn_allow_unlimited              = $openvpn['allow_unlimited']
  $openvpn_unlimited_prefix             = $openvpn['unlimited_prefix']
  $openvpn_unlimited_tcp_network_prefix = '10.41.0'
  $openvpn_unlimited_tcp_netmask        = '255.255.248.0'
  $openvpn_unlimited_tcp_cidr           = '21'
  $openvpn_unlimited_udp_network_prefix = '10.42.0'
  $openvpn_unlimited_udp_netmask        = '255.255.248.0'
  $openvpn_unlimited_udp_cidr           = '21'

  if !$::ec2_instance_id {
    $openvpn_allow_limited                = $openvpn['allow_limited']
    $openvpn_limited_prefix               = $openvpn['limited_prefix']
    $openvpn_rate_limit                   = $openvpn['rate_limit']
    $openvpn_limited_tcp_network_prefix   = '10.43.0'
    $openvpn_limited_tcp_netmask          = '255.255.248.0'
    $openvpn_limited_tcp_cidr             = '21'
    $openvpn_limited_udp_network_prefix   = '10.44.0'
    $openvpn_limited_udp_netmask          = '255.255.248.0'
    $openvpn_limited_udp_cidr             = '21'
  }

  # find out the netmask in cidr format of the primary IF
  # thx to https://blog.kumina.nl/tag/puppet-tips-and-tricks/
  # we can do this using an inline_template:
  $factname_primary_netmask = "netmask_${::site_config::params::interface}"
  $primary_netmask = inline_template('<%= scope.lookupvar(@factname_primary_netmask) %>')

  # deploy dh keys
  include site_openvpn::dh_key

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
      port       => '1194',
      proto      => 'tcp',
      local      => $unlimited_gateway_address,
      tls_remote => "\"${openvpn_unlimited_prefix}\"",
      server     => "${openvpn_unlimited_tcp_network_prefix}.0 ${openvpn_unlimited_tcp_netmask}",
      push       => "\"dhcp-option DNS ${openvpn_unlimited_tcp_network_prefix}.1\"",
      management => '127.0.0.1 1000',
      config     => $openvpn_config
    }
    site_openvpn::server_config { 'udp_config':
      port       => '1194',
      proto      => 'udp',
      local      => $unlimited_gateway_address,
      tls_remote => "\"${openvpn_unlimited_prefix}\"",
      server     => "${openvpn_unlimited_udp_network_prefix}.0 ${openvpn_unlimited_udp_netmask}",
      push       => "\"dhcp-option DNS ${openvpn_unlimited_udp_network_prefix}.1\"",
      management => '127.0.0.1 1001',
      config     => $openvpn_config
    }
  } else {
    tidy { '/etc/openvpn/tcp_config.conf': }
    tidy { '/etc/openvpn/udp_config.conf': }
  }

  if $openvpn_allow_limited {
    site_openvpn::server_config { 'limited_tcp_config':
      port       => '1194',
      proto      => 'tcp',
      local      => $limited_gateway_address,
      tls_remote => "\"${openvpn_limited_prefix}\"",
      server     => "${openvpn_limited_tcp_network_prefix}.0 ${openvpn_limited_tcp_netmask}",
      push       => "\"dhcp-option DNS ${openvpn_limited_tcp_network_prefix}.1\"",
      management => '127.0.0.1 1002',
      config     => $openvpn_config
    }
    site_openvpn::server_config { 'limited_udp_config':
      port       => '1194',
      proto      => 'udp',
      local      => $limited_gateway_address,
      tls_remote => "\"${openvpn_limited_prefix}\"",
      server     => "${openvpn_limited_udp_network_prefix}.0 ${openvpn_limited_udp_netmask}",
      push       => "\"dhcp-option DNS ${openvpn_limited_udp_network_prefix}.1\"",
      management => '127.0.0.1 1003',
      config     => $openvpn_config
    }
  } else {
    tidy { '/etc/openvpn/limited_tcp_config.conf': }
    tidy { '/etc/openvpn/limited_udp_config.conf': }
  }

  file {
    '/usr/local/bin/add_gateway_ips.sh':
      content => template('site_openvpn/add_gateway_ips.sh.erb'),
      mode    => '0755';
  }

  exec { '/usr/local/bin/add_gateway_ips.sh':
    subscribe   => File['/usr/local/bin/add_gateway_ips.sh'],
  }

  exec { 'restart_openvpn':
    command     => '/etc/init.d/openvpn restart',
    refreshonly => true,
    subscribe   => [
                    File['/etc/openvpn'],
                    Class['Site_config::X509::Key'],
                    Class['Site_config::X509::Cert'],
                    Class['Site_config::X509::Ca_bundle'] ],
    require     => [
                    Package['openvpn'],
                    File['/etc/openvpn'],
                    Class['Site_config::X509::Key'],
                    Class['Site_config::X509::Cert'],
                    Class['Site_config::X509::Ca_bundle'] ];
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
    'openvpn': ensure => latest
  }

  service {
    'openvpn':
      ensure     => running,
      hasrestart => true,
      hasstatus  => true,
      require    => [
        Package['openvpn'],
        Exec['concat_/etc/default/openvpn'] ];
  }

  file {
    '/etc/openvpn':
      ensure  => directory,
      notify  => Exec['restart_openvpn'],
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

  leap::logfile { 'openvpn_tcp': }
  leap::logfile { 'openvpn_udp': }

  # Because we currently do not support ipv6 and instead block it (so no leaks
  # happen), we get a large number of these messages, so we ignore them (#6540)
  rsyslog::snippet { '01-ignore_icmpv6_send':
    content => ':msg, contains, "icmpv6_send: no reply to icmp error" ~'
  }

  include site_check_mk::agent::openvpn

}
