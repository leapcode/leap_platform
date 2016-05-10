# remove tapicero leftovers from previous deploys on couchdb nodes
class site_config::remove::tapicero {

  ensure_packages('curl')

  # remove tapicero couchdb user
  $couchdb_config = hiera('couch')
  $couchdb_mode   = $couchdb_config['mode']

  if $couchdb_mode == 'multimaster'
  {
    $port = 5986
  } else {
    $port = 5984
  }

  exec { 'remove_couchdb_user':
    onlyif  => "/usr/bin/curl -s 127.0.0.1:${port}/_users/org.couchdb.user:tapicero | grep -qv 'not_found'",
    command => "/usr/local/bin/couch-doc-update --host 127.0.0.1:${port} --db _users --id org.couchdb.user:tapicero --delete",
    require => Package['curl']
  }


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
