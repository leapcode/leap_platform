class site_check_mk::agent::couchdb {

  file { '/etc/check_mk/logwatch.d/couchdb.cfg':
    source => 'puppet:///modules/site_check_mk/agent/logwatch/couchdb.cfg',
  }


  # local custom checks
  file { '/usr/lib/check_mk_agent/local/check_bigcouch_errors.sh':
    ensure  => link,
    target  => '/srv/leap/couchdb/scripts/tests/check_bigcouch_errors.sh',
    require => Vcsrepo['/srv/leap/couchdb/scripts']
  }

}
