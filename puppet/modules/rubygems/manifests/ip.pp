class rubygems::ip {
  require rubygems
  package{'ip':
    ensure => present,
    provider => gem,
  }
}
