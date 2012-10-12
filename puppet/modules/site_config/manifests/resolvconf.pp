class site_config::resolvconf {
  package { 'bind9':
    ensure => installed,
  }

  $domain_hash = hiera('domain')
  $domain_public = $domain_hash['public']

  # 127.0.0.1: caching-only local bind
  # 87.118.100.175: http://server.privacyfoundation.de
  class { '::resolvconf':
    domain      => $domain_public,
    search      => $domain_public,
    nameservers => [ '127.0.0.1', '87.118.100.175' ]
  }
}
