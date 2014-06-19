class site_apt::preferences::passenger {

  apt::preferences_snippet { 'passenger':
    package  => 'libapache2-mod-passenger',
    release  => "${::lsbdistcodename}-backports",
    priority => 999,
    require  => [Package['apache'], Class['ruby']];
  }

}
