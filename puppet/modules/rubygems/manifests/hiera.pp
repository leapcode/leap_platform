class rubygems::hiera{
  require ::rubygems
  package{'hiera':
    ensure => installed,
    provider => gem,
  }
}
