class squid_deb_proxy::server {
  package { 'squid-deb-proxy':
    ensure => installed,
  }

  service { 'squid-deb-proxy':
    ensure    => running,
    hasstatus => false,
    require   => Package[ 'squid-deb-proxy' ],
  }

  file {'/etc/squid-deb-proxy/mirror-dstdomain.acl.d/20-custom':
    source  => [ 'puppet:///modules/site_squid_deb_proxy/mirror-dstdomain.acl.d/20-custom',
      'puppet:///modules/squid_deb_proxy/mirror-dstdomain.acl.d/20-custom' ],
    notify  => Service[ 'squid-deb-proxy' ],
    require => Package[ 'squid-deb-proxy' ],
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
  }

  file {'/etc/squid-deb-proxy/allowed-networks-src.acl.d/20-custom':
    source  => [ 'puppet:///modules/site_squid_deb_proxy/allowed-networks-src.acl.d/20-custom',
      'puppet:///modules/squid_deb_proxy/allowed-networks-src.acl.d/20-custom' ],
    notify  => Service[ 'squid-deb-proxy' ],
    require => Package[ 'squid-deb-proxy' ],
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
  }

  file { '/etc/squid-deb-proxy/squid-deb-proxy.conf':
    source  => [ "puppet:///modules/site_squid_deb_proxy/${::operatingsystem}/squid-deb-proxy.conf",
      "puppet:///modules/squid_deb_proxy/${::operatingsystem}/squid-deb-proxy.conf" ],
    notify  => Service[ 'squid-deb-proxy' ],
    require => Package[ 'squid-deb-proxy' ],
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
  }
}
