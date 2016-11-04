class rubygems::camping {
  require rubygems::rack
  package{'camping':
    ensure => present,
    provider => gem,
  }
}
