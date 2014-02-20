class site_check_mk::agent::logwatch::syslog {

  concat { '/etc/check_mk/logwatch.d/syslog.cfg':
    warn    => true
  }

  concat::fragment { 'syslog_header':
    source => 'puppet:///modules/site_check_mk/agent/logwatch/syslog.cfg',
    target => '/etc/check_mk/logwatch.d/syslog.cfg',
    order  => '01';
  }

}
