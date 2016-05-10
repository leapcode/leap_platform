# setup apt on all nodes
class site_apt {

  $sources           = hiera('sources')
  $apt_config        = $sources['apt']

  # debian repo urls
  $apt_url_basic     = $apt_config['basic']
  $apt_url_security  = $apt_config['security']
  $apt_url_backports = $apt_config['backports']

  # leap repo url
  $platform_sources       = $sources['platform']
  $apt_url_platform_basic = $platform_sources['apt']['basic']

  # needed on jessie hosts for getting pnp4nagios from testing
  if ( $::operatingsystemmajrelease == '8' ) {
    $use_next_release = true
  } else {
    $use_next_release = false
  }

  class { 'apt':
    custom_key_dir   => 'puppet:///modules/site_apt/keys',
    debian_url       => $apt_url_basic,
    security_url     => $apt_url_security,
    backports_url    => $apt_url_backports,
    use_next_release => $use_next_release
  }

  # enable http://deb.leap.se debian package repository
  include site_apt::leap_repo

  apt::apt_conf { '90disable-pdiffs':
    content => 'Acquire::PDiffs "false";';
  }

  include ::site_apt::unattended_upgrades

  # not currently used
  #apt::sources_list { 'secondary.list':
  #  content => template('site_apt/secondary.list');
  #}

  apt::preferences_snippet { 'leap':
    priority => 999,
    package  => '*',
    pin      => 'origin "deb.leap.se"'
  }

  # All packages should be installed after 'update_apt' is called,
  # which does an 'apt-get update'.
  Exec['update_apt'] -> Package <||>

}
