class site_apt::preferences::obfsproxy {

  apt::preferences_snippet { 'obfsproxy':
    package  => 'obfsproxy',
    release  => "${::lsbdistcodename}-backports",
    priority => 999;
  }

}
