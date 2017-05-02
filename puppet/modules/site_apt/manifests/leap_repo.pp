# install leap deb repo together with leap-keyring package
# containing the apt signing key
class site_apt::leap_repo {
  $platform = hiera_hash('platform')
  $major_version = $platform['major_version']

  if $::site_apt::apt_url_platform_basic =~ /.*experimental.*/ {
    $archive_key = '/usr/share/keyrings/leap-experimental-archive.gpg'
  } else {
    $archive_key = '/usr/share/keyrings/leap-archive.gpg'
  }

  apt::sources_list { 'leap.list':
    content => "deb [signed-by=${archive_key}] ${::site_apt::apt_url_platform_basic} ${::site_apt::apt_platform_codename} ${::site_apt::apt_platform_component}\n",
    before  => Exec[refresh_apt]
  }

  package { 'leap-archive-keyring':
    ensure => latest
  }

}
