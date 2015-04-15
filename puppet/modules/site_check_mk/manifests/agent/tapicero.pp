class site_check_mk::agent::tapicero {

  include ::site_nagios::plugins

  # watch logs
  file { '/etc/check_mk/logwatch.d/tapicero.cfg':
    source => 'puppet:///modules/site_check_mk/agent/logwatch/tapicero.cfg',
  }

  # local nagios plugin checks via mrpe
  augeas {
    'Tapicero_Procs':
      incl    => '/etc/check_mk/mrpe.cfg',
      lens    => 'Spacevars.lns',
      changes => [
        'rm /files/etc/check_mk/mrpe.cfg/Tapicero_Procs',
        'set Tapicero_Procs "/usr/lib/nagios/plugins/check_procs -w 1:1 -c 1:1 -a tapicero"' ],
      require => File['/etc/check_mk/mrpe.cfg'];
  }
}
