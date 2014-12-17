class site_check_mk::agent::tapicero {

  include ::site_nagios::plugins

  concat::fragment { 'syslog_tapicero':
    source  => 'puppet:///modules/site_check_mk/agent/logwatch/syslog/tapicero.cfg',
    target  => '/etc/check_mk/logwatch.d/syslog.cfg',
    order   => '02';
  }

  # local nagios plugin checks via mrpe
  file_line {
    'Tapicero_Procs':
      line => 'Tapicero_Procs  /usr/lib/nagios/plugins/check_procs -w 1:1 -c 1:1 -a tapicero',
      path => '/etc/check_mk/mrpe.cfg';

    'Tapicero_Heartbeat':
      line => 'Tapicero_Heartbeat  /usr/local/lib/nagios/plugins/check_last_regex_in_log -f /var/log/syslog -r "tapicero" -w 300 -c 600',
      path => '/etc/check_mk/mrpe.cfg';
  }

}
