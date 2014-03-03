class site_check_mk::agent::logwatch::syslog {

  concat { '/etc/check_mk/logwatch.d/syslog.cfg':
    warn    => true
  }

  concat::fragment { 'syslog_header':
    source => 'puppet:///modules/site_check_mk/agent/logwatch/syslog_header.cfg',
    target => '/etc/check_mk/logwatch.d/syslog.cfg',
    order  => '01';
  }
  concat::fragment { 'syslog_tail':
    source => 'puppet:///modules/site_check_mk/agent/logwatch/syslog_tail.cfg',
    target => '/etc/check_mk/logwatch.d/syslog.cfg',
    order  => '99';
  }

}
