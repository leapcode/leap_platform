class site_check_mk::agent::couchdb {

  file { '/etc/check_mk/logwatch.d/bigcouch.cfg':
    source => 'puppet:///modules/site_check_mk/agent/logwatch/bigcouch.cfg',
  }

  concat::fragment { 'syslog_couchdb':
    source  => 'puppet:///modules/site_check_mk/agent/logwatch/syslog/couchdb.cfg',
    target  => '/etc/check_mk/logwatch.d/syslog.cfg',
    order   => '02';
  }

}
