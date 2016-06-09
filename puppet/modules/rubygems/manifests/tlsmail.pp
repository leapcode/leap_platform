class rubygems::tlsmail {
  require rubygems::devel
  package{'tlsmail':
    ensure => present,
    provider => gem,
  }
}
