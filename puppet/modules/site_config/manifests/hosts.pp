class site_config::hosts() {
  $hosts         = hiera('hosts', false)

  # calculate all the hostname aliases that might be used
  $hostname      = hiera('name')
  $domain_hash   = hiera('domain', {})
  $dns           = hiera('dns', {})
  if $dns['aliases'] == undef {
    $dns_aliases = []
  } else {
    $dns_aliases = $dns['aliases']
  }
  $my_hostnames = unique(sort(concat(
    [$hostname, $domain_hash['full'], $domain_hash['internal']],
    $dns_aliases
  )))

  file { '/etc/hostname':
    ensure  => present,
    content => $hostname
  }

  exec { "/bin/hostname ${hostname}":
    subscribe   => [ File['/etc/hostname'], File['/etc/hosts'] ],
    refreshonly => true;
  }

  # we depend on reliable hostnames from /etc/hosts for the stunnel services
  # so restart stunnel service when /etc/hosts is modified
  # because this is done in an early stage, the stunnel module may not
  # have been deployed and will not be available for overriding, so
  # this is handled in an unorthodox manner
  exec { '/etc/init.d/stunnel4 restart':
    subscribe   => File['/etc/hosts'],
    refreshonly => true,
    onlyif      => 'test -f /etc/init.d/stunnel4';
  }

  file { '/etc/hosts':
    content => template('site_config/hosts'),
    mode    => '0644',
    owner   => root,
    group   => root;
  }
}
