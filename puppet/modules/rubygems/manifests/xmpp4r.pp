class rubygems::xmpp4r {
  require ::rubygems
  package{'xmpp4r':
    ensure => present,
    provider => gem,
  }
}
