class rubygems::backports {
  require rubygems::devel
  package{'backports':
    ensure => present,
    provider => gem,
  }
}
