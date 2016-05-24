class rubygems::hiera_puppet {
  require rubygems::hiera
  package{'hiera-puppet':
    ensure => installed,
    provider => gem,
  }
}
