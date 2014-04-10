class site_check_mk::agent::webapp {

  # check webapp login + soledad sync
  package { [ 'python-srp', 'python-requests', 'python-yaml', 'python-u1db' ]:
    ensure => installed
  }
  file { '/usr/lib/check_mk_agent/local/nagios-webapp_login.py':
    ensure  => link,
    target  => '/srv/leap/webapp/test/nagios/webapp_login.py',
    require => Package['check_mk-agent']
  }
  file { '/usr/lib/check_mk_agent/local/soledad_sync.py':
    ensure  => link,
    target  => '/srv/leap/webapp/test/nagios/soledad_sync.py',
    require => Package['check_mk-agent']
  }


  # check syslog
  concat::fragment { 'syslog_webapp':
    source  => 'puppet:///modules/site_check_mk/agent/logwatch/syslog/webapp.cfg',
    target  => '/etc/check_mk/logwatch.d/syslog.cfg',
    order   => '02';
  }

}
