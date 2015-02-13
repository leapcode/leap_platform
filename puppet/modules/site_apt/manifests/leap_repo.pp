class site_apt::leap_repo {
  $platform = hiera_hash('platform')
  $major_version = $platform['major_version']

  apt::sources_list { 'leap.list':
    content => template('site_apt/leap.list.erb'),
    before  => Exec[refresh_apt]
  }

  package { 'leap-keyring':
    ensure => latest
  }

  # We wont be able to install the leap-keyring package unless the leap apt
  # source has been added and apt has been refreshed
  Exec['refresh_apt'] -> Package['leap-keyring']
}
