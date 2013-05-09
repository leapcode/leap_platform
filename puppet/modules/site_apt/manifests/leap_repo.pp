class site_apt::leap_repo {
  apt::sources_list { 'leap.list':
    content => 'deb http://deb.leap.se/debian stable main',
    before  => Exec[refresh_apt]
  }

}
