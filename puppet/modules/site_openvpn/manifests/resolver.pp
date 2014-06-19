class site_openvpn::resolver {

  if $site_openvpn::openvpn_allow_unlimited {
    $ensure_unlimited = 'present'
    file {
      '/etc/unbound/unbound.conf.d/vpn_unlimited_udp_resolver.conf':
        content => "server:\n\tinterface: ${site_openvpn::openvpn_unlimited_udp_network_prefix}.1\n\taccess-control: ${site_openvpn::openvpn_unlimited_udp_network_prefix}.0/${site_openvpn::openvpn_unlimited_udp_cidr} allow\n",
        owner   => root,
        group   => root,
        mode    => '0644',
        require => [ Class['site_config::caching_resolver'], Service['openvpn'] ],
        notify  => Service['unbound'];
      '/etc/unbound/unbound.conf.d/vpn_unlimited_tcp_resolver.conf':
        content => "server:\n\tinterface: ${site_openvpn::openvpn_unlimited_tcp_network_prefix}.1\n\taccess-control: ${site_openvpn::openvpn_unlimited_tcp_network_prefix}.0/${site_openvpn::openvpn_unlimited_tcp_cidr} allow\n",
        owner   => root,
        group   => root,
        mode    => '0644',
        require => [ Class['site_config::caching_resolver'], Service['openvpn'] ],
        notify  => Service['unbound'];
    }
  } else {
    $ensure_unlimited = 'absent'
    tidy { '/etc/unbound/unbound.conf.d/vpn_unlimited_udp_resolver.conf': }
    tidy { '/etc/unbound/unbound.conf.d/vpn_unlimited_tcp_resolver.conf': }
  }

  if $site_openvpn::openvpn_allow_limited {
    $ensure_limited = 'present'
    file {
      '/etc/unbound/unbound.conf.d/vpn_limited_udp_resolver.conf':
        content => "server:\n\tinterface: ${site_openvpn::openvpn_limited_udp_network_prefix}.1\n\taccess-control: ${site_openvpn::openvpn_limited_udp_network_prefix}.0/${site_openvpn::openvpn_limited_udp_cidr} allow\n",
        owner   => root,
        group   => root,
        mode    => '0644',
        require => [ Class['site_config::caching_resolver'], Service['openvpn'] ],
        notify  => Service['unbound'];
      '/etc/unbound/unbound.conf.d/vpn_limited_tcp_resolver.conf':
        content => "server\n\tinterface: ${site_openvpn::openvpn_limited_tcp_network_prefix}.1\n\taccess-control: ${site_openvpn::openvpn_limited_tcp_network_prefix}.0/${site_openvpn::openvpn_limited_tcp_cidr} allow\n",
        owner   => root,
        group   => root,
        mode    => '0644',
        require => [ Class['site_config::caching_resolver'], Service['openvpn'] ],
        notify  => Service['unbound'];
    }
  } else {
    $ensure_limited = 'absent'
    tidy { '/etc/unbound/unbound.conf.d/vpn_limited_udp_resolver.conf': }
    tidy { '/etc/unbound/unbound.conf.d/vpn_limited_tcp_resolver.conf': }
  }
}
