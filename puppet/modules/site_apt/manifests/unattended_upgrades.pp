class site_apt::unattended_upgrades {
  # override unattended-upgrades package resource to make sure
  # that it is upgraded on every deploy (#6245)

  class { 'apt::unattended_upgrades':
    config_content => template('site_apt/50unattended-upgrades'),
    ensure_version => latest
  }
}
