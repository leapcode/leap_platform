class site_check_mk::agent::tapicero {

  concat::fragment { 'syslog_tapicero':
    source  => 'puppet:///modules/site_check_mk/agent/logwatch/tapicero.cfg',
    target  => '/etc/check_mk/logwatch.d/syslog.cfg',
    order   => '02';
  }

  # local nagios plugin checks via mrpe
  file_line {
    'Tapicero_Procs':
      line => 'Tapicero_Procs  /usr/lib/nagios/plugins/check_procs -w 1:1 -c 1:1 -a tapicero',
      path => '/etc/check_mk/mrpe.cfg';
  }

}
