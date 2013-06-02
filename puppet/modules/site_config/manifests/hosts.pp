class site_config::hosts() {
  $hosts         = hiera('hosts','')
  $hostname      = hiera('name')
  $domain_hash   = hiera('domain')
  $domain_public = $domain_hash['full_suffix']

  file { '/etc/hostname':
    ensure  => present,
    content => $hostname
  }

  exec { "/bin/hostname ${hostname}":
    subscribe   => [ File['/etc/hostname'], File['/etc/hosts'] ],
    refreshonly => true;
  }

  file { '/etc/hosts':
    content => template('site_config/hosts'),
    mode    => '0644',
    owner   => root,
    group   => root;
  }
}
