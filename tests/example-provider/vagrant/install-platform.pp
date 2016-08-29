class {'apt': }
Exec['update_apt'] -> Package <||>

# install leap_cli from source, so it will work with the develop
# branch of leap_platform
class { '::leap::cli::install':
  source  => true,
}

file { [ '/srv/leap', '/srv/leap/configuration', '/var/log/leap' ]:
  ensure => directory
}

# install prerequisites for configuring the provider
include ::git
