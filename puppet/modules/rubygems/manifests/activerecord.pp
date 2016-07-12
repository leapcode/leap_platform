class rubygems::activerecord {
  require rubygems
  package{'activerecord':
    ensure => present,
    provider => gem,
  }
}
