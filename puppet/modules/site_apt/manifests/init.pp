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
  $apt_platform_component = $platform_sources['apt']['component']

  if ( $platform_sources['apt']['codename'] == '') {
    $apt_platform_codename = $::lsbdistcodename
  } else {
    $apt_platform_codename = $platform_sources['apt']['codename']
  }

  # needed on jessie hosts for getting python-treq from stretch
  # see https://0xacab.org/leap/platform/issues/8836
  if ( $::operatingsystemmajrelease == '8' ) {
    $use_next_release   = true
    $custom_preferences = template("site_apt/${::operatingsystem}/preferences_jessie.erb")
  } else {
    $use_next_release   = false
    $custom_preferences = ''
  }

  class { 'apt':
    custom_key_dir     => 'puppet:///modules/site_apt/keys',
    debian_url         => $apt_url_basic,
    security_url       => $apt_url_security,
    backports_url      => $apt_url_backports,
    use_next_release   => $use_next_release,
    custom_preferences => $custom_preferences,
    repos              => 'main'
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
