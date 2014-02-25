class site_check_mk::agent::couchdb {

  # watch logs
  file { '/etc/check_mk/logwatch.d/bigcouch.cfg':
    source => 'puppet:///modules/site_check_mk/agent/logwatch/bigcouch.cfg',
  }
  concat::fragment { 'syslog_couchdb':
    source  => 'puppet:///modules/site_check_mk/agent/logwatch/syslog/couchdb.cfg',
    target  => '/etc/check_mk/logwatch.d/syslog.cfg',
    order   => '02';
  }


  # check bigcouch processes
  file_line {
    'Bigcouch_epmd_procs':
      line => 'Bigcouch_epmd_procs  /usr/lib/nagios/plugins/check_procs -w 1:1 -c 1:1 -a /opt/bigcouch/erts-5.9.1/bin/epmd',
      path => '/etc/check_mk/mrpe.cfg';
    'Bigcouch_beam_procs':
      line => 'Bigcouch_beam_procs  /usr/lib/nagios/plugins/check_procs -w 1:1 -c 1:1 -a /opt/bigcouch/erts-5.9.1/bin/beam',
      path => '/etc/check_mk/mrpe.cfg';
  }


}
