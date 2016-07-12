class check_mk::omd_repo {
  apt::sources_list { 'omd.list':
    content => "deb http://labs.consol.de/OMD/debian ${::lsbdistcodename} main",
    before  => Package['omd']
  }
}
