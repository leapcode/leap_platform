class site_config::resolvconf {
  package { 'bind9':
    ensure => installed,
  }

  $domain_hash = hiera('domain')
  $domain = $domain_hash['public']

  $resolvconf_search = $domain
  $resolvconf_domain = $domain
  $resolvconf_nameservers = '127.0.0.1 # caching-only local bind:87.118.100.175  # http://server.privacyfoundation.de'
  include resolvconf
}
