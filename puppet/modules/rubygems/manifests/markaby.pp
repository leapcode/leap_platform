class rubygems::markaby {
  require rubygems
  package{'markaby':
    ensure => present,
    provider => gem,
  }
}
