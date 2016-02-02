# install leap deb repo together with leap-keyring package
# containing the apt signing key
class site_apt::leap_repo {
  $platform = hiera_hash('platform')
  $major_version = $platform['major_version']

  apt::sources_list { 'leap.list':
    content => "deb ${::site_apt::apt_url_platform_basic} ${::lsbdistcodename} main\n",
    before  => Exec[refresh_apt]
  }

  package { 'leap-keyring':
    ensure => latest
  }

}
