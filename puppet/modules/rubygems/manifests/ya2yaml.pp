class rubygems::ya2yaml {
  require rubygems
  package{'ya2yaml':
    ensure => present,
    provider => gem,
  }
}
