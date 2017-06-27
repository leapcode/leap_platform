# configute unattended upgrades so packages from both Debian and LEAP
# repos get upgraded unattended
class site_apt::unattended_upgrades {
  # override unattended-upgrades package resource to make sure
  # that it is upgraded on every deploy (#6245)

  # configure upgrades for Debian
  class { 'apt::unattended_upgrades':
    ensure_version => latest
  }

  # configure LEAP upgrades
  apt::apt_conf { '51unattended-upgrades-leap':
    content     => template('site_apt/51unattended-upgrades-leap'),
    require     => Package['unattended-upgrades'],
    refresh_apt => false,
  }

}
