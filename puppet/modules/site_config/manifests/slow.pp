class site_config::slow {
  tag 'leap_slow'
  class { 'site_apt::dist_upgrade':
    stage => initial,
  }
}
