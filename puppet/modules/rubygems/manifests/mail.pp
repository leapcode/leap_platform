# manage the mail rubygem
class rubygems::mail {
  if ($::osfamily == 'RedHat') and
    versioncmp($::operatingsystemrelease,'6') > 0 {
    package{'rubygem-mail':
      ensure => present,
    }
  } else {
    require rubygems::devel
    package{'mail':
      ensure   => present,
      provider => gem,
    }

    if $::rubyversion == '1.8.6' {
      require rubygems::tlsmail
    }
  }
}
