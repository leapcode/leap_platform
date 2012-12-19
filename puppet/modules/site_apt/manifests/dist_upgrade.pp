class site_apt::dist_upgrade inherits apt::dist_upgrade {

  # really upgrade on every puppetrun
  Exec["apt_dist-upgrade"]{
    refreshonly => false,  
  }

  # Ensure apt-get upgrade has been run before installing any packages
  # Disables because apt-get update is moved to stage initial
  # Exec["apt_dist-upgrade"] -> Package <| name != 'lsb-release' |> 
}
