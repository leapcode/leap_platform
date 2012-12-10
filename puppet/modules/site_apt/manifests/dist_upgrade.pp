class site_apt::dist_upgrade inherits apt::dist_upgrade {

  # really upgrade on every puppetrun
  Exec["apt_dist-upgrade"]{
    refreshonly => false,  
  }

  # Ensure apt-get upgrade has been run before installing any packages
  Exec["apt_dist-upgrade"] -> Package <| name != 'lsb-release' |> 
}
