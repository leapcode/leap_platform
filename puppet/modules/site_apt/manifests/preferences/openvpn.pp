class site_apt::preferences::openvpn {

  apt::preferences_snippet { 'openvpn':
    package  => 'openvpn',
    release  => "${::lsbdistcodename}-backports",
    priority => 999;
  }

}
