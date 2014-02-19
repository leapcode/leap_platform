class site_check_mk::agent::tapicero {

  file { '/etc/check_mk/logwatch.d/tapicero.cfg':
    source => 'puppet:///modules/site_check_mk/agent/logwatch/tapicero.cfg',
  }

  # local nagios plugin checks via mrpe
  file_line {
    'Tapicero_Procs':
      line => 'Tapicero_Procs  /usr/lib/nagios/plugins/check_procs -w 1:1 -c 1:1 -a tapicero',
      path => '/etc/check_mk/mrpe.cfg';
  }

}
