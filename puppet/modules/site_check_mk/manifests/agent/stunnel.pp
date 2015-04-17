class site_check_mk::agent::stunnel {

  concat::fragment { 'syslog_stunnel':
    source  => 'puppet:///modules/site_check_mk/agent/logwatch/stunnel.cfg',
    target  => '/etc/check_mk/logwatch.d/syslog.cfg',
    order   => '02';
  }

}
