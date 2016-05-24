class rubygems::moneta {
  require rubygems
  package{'moneta':
    ensure => present,
    provider => gem,
  }
}
