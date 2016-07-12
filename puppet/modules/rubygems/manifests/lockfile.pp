class rubygems::lockfile {
  require rubygems
  package{'lockfile':
    ensure => present,
    provider => gem,
  }
}
