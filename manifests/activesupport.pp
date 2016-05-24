class rubygems::activesupport {
  require rubygems
  package{'activesupport':
    ensure => present,
    provider => gem,
  }
}
