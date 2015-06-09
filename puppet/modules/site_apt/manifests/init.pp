# setup apt on all nodes
class site_apt {

  $sources           = hiera('sources')
  $apt_config        = $sources['apt']
  $apt_url_basic     = $apt_config['basic']
  $apt_url_security  = $apt_config['security']
  $apt_url_backports = $apt_config['backports']

  class { 'apt':
    custom_key_dir => 'puppet:///modules/site_apt/keys',
    debian_url     => $apt_url_basic,
    security_url   => $apt_url_security,
    backports_url  => $apt_url_backports
  }

  # enable http://deb.leap.se debian package repository
  include site_apt::leap_repo

  apt::apt_conf { '90disable-pdiffs':
    content => 'Acquire::PDiffs "false";';
  }

  include ::site_apt::unattended_upgrades

  apt::sources_list { 'secondary.list.disabled':
    content => template('site_apt/secondary.list');
  }

  apt::preferences_snippet { 'facter':
    release  => "${::lsbdistcodename}-backports",
    priority => 999
  }

  apt::preferences_snippet { 'leap':
    priority => 999,
    package  => '*',
    pin      => 'origin "deb.leap.se"'
  }

  # All packages should be installed _after_ refresh_apt is called,
  # which does an apt-get update.
  # There is one exception:
  # The creation of sources.list depends on the lsb package

  File['/etc/apt/preferences'] ->
    Apt::Preferences_snippet <| |> ->
    Exec['refresh_apt'] ->
    Package <| ( title != 'lsb' ) |>
}
