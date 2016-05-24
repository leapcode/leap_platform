class rubygems::bcrypt {
  if ($::osfamily == 'RedHat') and
    versioncmp($::operatingsystemrelease,'6') > 0 {
    package{'rubygem-bcrypt':
      ensure => present,
    }
  } else {
    require rubygems
    package{'bcrypt-ruby':
      ensure => present,
      provider => gem,
    }
  }
}
