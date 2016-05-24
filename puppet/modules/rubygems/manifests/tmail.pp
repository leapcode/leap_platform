class rubygems::tmail {
  require rubygems::devel
  package{'tmail':
    ensure => present,
    provider => gem,
  }
}
