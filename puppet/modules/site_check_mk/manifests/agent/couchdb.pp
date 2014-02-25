class site_check_mk::agent::couchdb {

  file { '/etc/check_mk/logwatch.d/couchdb.cfg':
    source => 'puppet:///modules/site_check_mk/agent/logwatch/couchdb.cfg',
  }
}
