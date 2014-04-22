class site_apt::preferences::twisted {

  apt::preferences_snippet { 'python-twisted':
    package  => 'python-twisted*',
    release  => "${::lsbdistcodename}-backports",
    priority => 999;
  }

}
