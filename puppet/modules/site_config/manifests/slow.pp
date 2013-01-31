class site_config::slow {

  class { 'site_apt::dist_upgrade':
    stage => initial,
  }
}
