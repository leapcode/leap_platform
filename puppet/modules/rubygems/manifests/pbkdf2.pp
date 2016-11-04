class rubygems::pbkdf2{
  require ::rubygems
  package{'pbkdf2':
    ensure => installed,
    provider => gem,
  }
}

