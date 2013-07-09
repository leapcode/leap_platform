class site_openvpn::resolver {

  if $site_openvpn::openvpn_allow_unlimited {
    $ensure_unlimited = 'present'
    file {
      '/etc/unbound/conf.d/vpn_unlimited_udp_resolver':
        content => "interface: ${site_openvpn::openvpn_unlimited_udp_network_prefix}.1\naccess-control: ${site_openvpn::openvpn_unlimited_udp_network_prefix}.0/${site_openvpn::openvpn_unlimited_udp_cidr} allow\n",
        owner   => root,
        group   => root,
        mode    => '0644',
        require => Service['openvpn'],
        notify  => Service['unbound'];
      '/etc/unbound/conf.d/vpn_unlimited_tcp_resolver':
        content => "interface: ${site_openvpn::openvpn_unlimited_tcp_network_prefix}.1\naccess-control: ${site_openvpn::openvpn_unlimited_tcp_network_prefix}.0/${site_openvpn::openvpn_unlimited_tcp_cidr} allow\n",
        owner   => root,
        group   => root,
        mode    => '0644',
        require => Service['openvpn'],
        notify  => Service['unbound'];
    }
  } else {
    $ensure_unlimited = 'absent'
    tidy { '/etc/unbound/conf.d/vpn_unlimited_udp_resolver': }
    tidy { '/etc/unbound/conf.d/vpn_unlimited_tcp_resolver': }
  }

  if $site_openvpn::openvpn_allow_limited {
    $ensure_limited = 'present'
    file {
      '/etc/unbound/conf.d/vpn_limited_udp_resolver':
        content => "interface: ${site_openvpn::openvpn_limited_udp_network_prefix}.1\naccess-control: ${site_openvpn::openvpn_limited_udp_network_prefix}.0/${site_openvpn::openvpn_limited_udp_cidr} allow\n",
        owner   => root,
        group   => root,
        mode    => '0644',
        require => Service['openvpn'],
        notify  => Service['unbound'];
      '/etc/unbound/conf.d/vpn_limited_tcp_resolver':
        content => "interface: ${site_openvpn::openvpn_limited_tcp_network_prefix}.1\naccess-control: ${site_openvpn::openvpn_limited_tcp_network_prefix}.0/${site_openvpn::openvpn_limited_tcp_cidr} allow\n",
        owner   => root,
        group   => root,
        mode    => '0644',
        require => Service['openvpn'],
        notify  => Service['unbound'];
    }
  } else {
    $ensure_limited = 'absent'
    tidy { '/etc/unbound/conf.d/vpn_limited_udp_resolver': }
    tidy { '/etc/unbound/conf.d/vpn_limited_tcp_resolver': }
  }

  # this is an unfortunate way to get around the fact that the version of
  # unbound we are working with does not accept a wildcard include directive
  # (/etc/unbound/conf.d/*), when it does, these line definitions should
  # go away and instead the caching_resolver should be configured to
  # include: /etc/unbound/conf.d/*

  file_line {
    'add_unlimited_tcp_resolver':
      ensure  => $ensure_unlimited,
      path    => '/etc/unbound/unbound.conf',
      line    => 'server: include: /etc/unbound/conf.d/vpn_unlimited_tcp_resolver',
      notify  => Service['unbound'],
      require => Package['unbound'];
    'add_unlimited_udp_resolver':
      ensure  => $ensure_unlimited,
      path    => '/etc/unbound/unbound.conf',
      line    => 'server: include: /etc/unbound/conf.d/vpn_unlimited_udp_resolver',
      notify  => Service['unbound'],
      require => Package['unbound'];
    'add_limited_tcp_resolver':
      ensure  => $ensure_limited,
      path    => '/etc/unbound/unbound.conf',
      line    => 'server: include: /etc/unbound/conf.d/vpn_limited_tcp_resolver',
      notify  => Service['unbound'],
      require => Package['unbound'];
    'add_limited_udp_resolver':
      ensure  => $ensure_limited,
      path    => '/etc/unbound/unbound.conf',
      line    => 'server: include: /etc/unbound/conf.d/vpn_limited_udp_resolver',
      notify  => Service['unbound'],
      require => Package['unbound']
  }

}
