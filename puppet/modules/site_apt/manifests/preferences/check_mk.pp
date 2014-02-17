class site_apt::preferences::check_mk {

  apt::preferences_snippet { 'check-mk':
    package  => 'check-mk-*',
    release  => "${::lsbdistcodename}-backports",
    priority => 999;
  }

}
