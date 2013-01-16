class site_config::resolvconf {

  # bind9
  package { 'bind9':
    ensure => absent,
  }

  service { 'bind9':
    ensure => stopped,
    require => Package['bind9'],
  }

  file { '/etc/default/bind9':
    ensure    => absent;
  }

  file { '/etc/bind/named.conf.options':
    ensure => absent;
  }

  $domain_hash = hiera('domain')
  $domain_public = $domain_hash['public']

  # 127.0.0.1:      caching-only local bind
  # 87.118.100.175: http://server.privacyfoundation.de
  # 62.141.58.13:   http://www.privacyfoundation.ch/de/service/server.html
  class { '::resolvconf':
    domain      => $domain_public,
    search      => $domain_public,
    nameservers => [ '127.0.0.1', '87.118.100.175', '62.141.58.13' ]
  }
}
