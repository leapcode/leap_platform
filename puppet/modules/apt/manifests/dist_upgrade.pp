class apt::dist_upgrade {

  exec { 'apt_dist-upgrade':
    command     => '/usr/bin/apt-get -q -y -o \'DPkg::Options::=--force-confold\' dist-upgrade',
    refreshonly => true,
    before      => Exec['apt_updated']
  }

}
