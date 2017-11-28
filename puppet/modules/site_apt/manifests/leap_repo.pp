# install leap deb repo together with leap-keyring package
# containing the apt signing key
class site_apt::leap_repo {
  $platform = hiera_hash('platform')
  $major_version = $platform['major_version']

  # on jessie, keys need to be in /etc/apt/...
  # see https://0xacab.org/leap/platform/issues/8862
  if ( $::operatingsystemmajrelease == '8' ) {
    if $::site_apt::apt_platform_component =~ /.*(staging|master).*/ {
      $archive_key = 'CE433F407BAB443AFEA196C1837C1AD5367429D9'
    } else {
      $archive_key = '1E453B2CE87BEE2F7DFE99661E34A1828E207901'
    }
  }
  if ( $::operatingsystemmajrelease != '8' ) {
    if $::site_apt::apt_platform_component =~ /.*(staging|master).*/ {
      $archive_key = '/usr/share/keyrings/leap-experimental-archive.gpg'
    } else {
      $archive_key = '/usr/share/keyrings/leap-archive.gpg'
    }
  }

  apt::sources_list { 'leap.list':
    content => "deb [signed-by=${archive_key}] ${::site_apt::apt_url_platform_basic} ${::site_apt::apt_platform_component} ${::site_apt::apt_platform_codename}\n",
    before  => Exec[refresh_apt]
  }

  package { 'leap-archive-keyring':
    ensure => latest
  }

}
