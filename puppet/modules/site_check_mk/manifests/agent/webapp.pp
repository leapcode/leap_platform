class site_check_mk::agent::webapp {

  concat::fragment { 'syslog_webapp':
    source  => 'puppet:///modules/site_check_mk/agent/logwatch/syslog/webapp.cfg',
    target  => '/etc/check_mk/logwatch.d/syslog.cfg',
    order   => '02';
  }

}
