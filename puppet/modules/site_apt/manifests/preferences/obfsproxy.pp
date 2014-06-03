class site_apt::preferences::obfsproxy {

  apt::preferences_snippet { 'obfsproxy':
    package  => 'obfsproxy',
    release  => 'wheezy-backports',
    priority => 999;
  }

}
