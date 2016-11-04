# configure logwatch and nagios checks for couchdb
class site_check_mk::agent::couchdb {

  concat::fragment { 'syslog_couchdb':
    source  => 'puppet:///modules/site_check_mk/agent/logwatch/syslog/couchdb.cfg',
    target  => '/etc/check_mk/logwatch.d/syslog.cfg',
    order   => '02';
  }

  # check different couchdb stats
  file { '/usr/lib/check_mk_agent/local/leap_couch_stats.sh':
    source  => 'puppet:///modules/site_check_mk/agent/local_checks/couchdb/leap_couch_stats.sh',
    mode    => '0755',
    require => Package['check_mk-agent']
  }
}
