# remove tapicero leftovers from previous deploys
class site_config::remove::tapicero {

  exec { 'kill_tapicero':
    onlyif  => '/usr/bin/test -s /var/run/tapicero.pid',
    command => '/usr/bin/pkill --pidfile /var/run/tapicero.pid'
  }

  user { 'tapicero':
    ensure  => absent;
  }

  group { 'tapicero':
    ensure => absent,
    require => User['tapicero'];
  }

  tidy {
    '/srv/leap/tapicero':
      recurse => true,
      require   => [ Exec['kill_tapicero'] ];
    '/var/lib/leap/tapicero':
      require   => [ Exec['kill_tapicero'] ];
    '/var/run/tapicero':
      require   => [ Exec['kill_tapicero'] ];
    '/etc/leap/tapicero.yaml':
      require   => [ Exec['kill_tapicero'] ];
    '/etc/init.d/tapicero':
      require   => [ Exec['kill_tapicero'] ];
    'tapicero_logs':
      path    => '/var/log/leap',
      recurse => true,
      matches => 'tapicero*',
      require   => [ Exec['kill_tapicero'] ];
    '/etc/check_mk/logwatch.d/tapicero.cfg':;
    'checkmk_logwatch_spool':
      path    => '/var/lib/check_mk/logwatch',
      recurse => true,
      matches => '*tapicero.log',
      require => Exec['kill_tapicero'],
  }

  # remove local nagios plugin checks via mrpe
  augeas {
    'Tapicero_Procs':
      incl    => '/etc/check_mk/mrpe.cfg',
      lens    => 'Spacevars.lns',
      changes => 'rm /files/etc/check_mk/mrpe.cfg/Tapicero_Procs',
      require => File['/etc/check_mk/mrpe.cfg'];
    'Tapicero_Heartbeat':
      incl    => '/etc/check_mk/mrpe.cfg',
      lens    => 'Spacevars.lns',
      changes => 'rm Tapicero_Heartbeat',
      require => File['/etc/check_mk/mrpe.cfg'];
  }

}
