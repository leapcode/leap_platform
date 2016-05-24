class rubygems::gpgme{
  case $::operatingsystem {
    debian,ubuntu: {
      case $::lsbdistcodename {
        'lenny','squeeze': {
          # install gpgme as gem, as the squeeze deb-package is too old
          # for i.e. gpg module
          $provider    = 'gem'
          $packagename = 'ruby-gpgme'
          }
        default:  {
          # don't need to install gpgme as gem, debian package works
          # fine with the gpg module
          $provider    = 'apt'
          $packagename = 'libgpgme-ruby'
        }
      }
    }
    default: {
      $provider = 'gem'
      $packagename = 'ruby-gpgme'
    }
  }

  if $provider == 'gem' {
    require rubygems::devel
    require gpg::gpgme::devel
  }

  package{'ruby-gpgme':
    ensure   => present,
    provider => $provider,
    name     => $packagename
  }
}
