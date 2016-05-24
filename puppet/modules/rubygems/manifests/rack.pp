class rubygems::rack {
  require rubygems
  package{'rack':
    ensure => present,
    provider => gem,
  }
}
