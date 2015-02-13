class site_apt {

  $sources           = hiera('sources')
  $apt_config        = $sources['apt']
  $apt_url_basic     = $apt_config['basic']
  $apt_url_security  = $apt_config['security']
  $apt_url_backports = $apt_config['backports']
  $apt_url_mirrors   = $apt_config['mirrors']
  $apt_url_leap      = ['http://deb.leap.se/']

  class { 'apt':
    custom_sources_list => template('site_apt/sources.list.erb'),
    custom_key_dir => 'puppet:///modules/site_apt/keys'
  }

  # enable http://deb.leap.se debian package repository
  include site_apt::leap_repo

  apt::apt_conf { '90disable-pdiffs':
    content => 'Acquire::PDiffs "false";';
  }

  # skip the "Translation" hits during `apt-get update`
  apt::apt_conf { '90disable-language':
    content => 'Acquire::Languages "none";';
  }

  include ::site_apt::unattended_upgrades

  include ::site_apt::apt_fast

  apt::sources_list { 'secondary.list.disabled':
    content => template('site_apt/secondary.list');
  }

  apt::preferences_snippet { 'facter':
    release  => "${::lsbdistcodename}-backports",
    priority => 999
  }

  # All packages should be installed _after_ refresh_apt is called,
  # which does an apt-get update.
  # There is one exception:
  # The creation of sources.list depends on the lsb package

  File['/etc/apt/preferences'] ->
    Exec['refresh_apt'] ->
      Package <| ( title != 'lsb' ) |>
}
