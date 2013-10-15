class site_config::resolvconf {

  $domain_public = $site_config::default::domain_hash['full_suffix']

  class { '::resolvconf':
    domain      => $domain_public,
    search      => $domain_public,
    nameservers => [
      '127.0.0.1      # local caching-only, unbound',
      '85.214.20.141  # Digitalcourage, a german privacy organisation: (https://en.wikipedia.org/wiki/Digitalcourage)',
      '62.141.58.13   # Swiss privacy Foundation (http://www.privacyfoundation.ch/de/service/server.html)'
    ]
  }
}
