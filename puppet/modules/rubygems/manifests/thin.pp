class rubygems::thin {
  require rubygems
  package{'thin':
    ensure => present,
    provider => gem,
  }
}
