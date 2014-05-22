class site_apt::preferences::unbound {

  apt::preferences_snippet { 'unbound':
    package  => 'libunbound* unbound*',
    release  => "${::lsbdistcodename}-backports",
    priority => 999,
    before   => Class['unbound::package'];
  }

}
