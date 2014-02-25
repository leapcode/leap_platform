class site_check_mk::agent::couchdb {

  file { '/etc/check_mk/logwatch.d/bigcouch.cfg':
    source => 'puppet:///modules/site_check_mk/agent/logwatch/bigcouch.cfg',
  }

}
