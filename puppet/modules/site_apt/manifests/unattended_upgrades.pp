class site_apt::unattended_upgrades inherits apt::unattended_upgrades {
  # override unattended-upgrades package resource to make sure
  # that it is upgraded on every deploy (#6245)

  include ::apt::unattended_upgrades

  Package['unattended-upgrades'] {
    ensure => latest
  }
}
