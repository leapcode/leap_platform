class rubygems::systemu {
  require rubygems
  package{'systemu':
    ensure => present,
    provider => gem,
  }
}
