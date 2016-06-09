class rubygems::open4 {
  require rubygems
  package{'open4':
    ensure => present,
    provider => gem,
  }
}
