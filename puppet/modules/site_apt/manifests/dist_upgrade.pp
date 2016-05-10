# upgrade all packages
class site_apt::dist_upgrade {

  # facter returns 'true' as string
  # lint:ignore:quoted_booleans
  if $::apt_running == 'true' {
  # lint:endignore
    fail ('apt-get is running in background - Please wait until it finishes. Exiting.')
  } else {
    exec{'initial_apt_dist_upgrade':
      command     => "/usr/bin/apt-get -q -y -o 'DPkg::Options::=--force-confold'  dist-upgrade",
      refreshonly => false,
      timeout     => 1200,
      require     => Exec['apt_updated']
    }
  }
}
