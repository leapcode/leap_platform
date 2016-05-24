class rubygems::postgres {
  if $::osfamily == 'RedHat' and
    versioncmp($::operatingsystemrelease,'5') > 0 {
    package{'rubygem-pg':
      ensure => installed,
    }
  } else {
    require postgres::devel
    rubygems::gem{'ruby-pg':}
  }
}
