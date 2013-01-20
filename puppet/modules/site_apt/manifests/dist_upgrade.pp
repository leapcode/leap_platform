class site_apt::dist_upgrade inherits apt::dist_upgrade {

  if $::apt_running == 'true' { 
    fail ('apt-get is running in background - Please wait until it finishes. Exiting.')
  }
  # ensue dist-upgrade on every puppetrun
  Exec['apt_dist-upgrade']{
    refreshonly => false,
  }

}
