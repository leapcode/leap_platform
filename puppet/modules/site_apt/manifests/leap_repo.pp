class site_apt::leap_repo {
  apt::sources_list { 'leap.list':
    content => 'deb http://deb.leap.se/debian stable main',
    before  => Exec[refresh_apt]
  }

  package { 'leap-keyring':
    ensure => latest
  }

  # We wont be able to install the leap-keyring package unless the leap apt
  # source has been added and apt has been refreshed
  Exec['refresh_apt'] -> Package['leap-keyring']
}
