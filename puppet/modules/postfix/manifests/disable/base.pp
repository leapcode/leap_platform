class postfix::disable::base {

  service{'postfix':
    ensure => stopped,
    enable => false,
  }
  package{'postfix':
    ensure => absent,
    require => Service['postfix'],
  }

}
