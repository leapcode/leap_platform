class rubygems::sinatra {
  require rubygems
  package{'sinatra':
    ensure => present,
    provider => gem,
  }
}
