class site_check_mk::agent::webapp {

  # check webapp login
  package { [ 'python-srp', 'python-requests', 'python-yaml' ]:
    ensure => installed
  }
  file { '/usr/lib/check_mk_agent/local/nagios-webapp_login.py':
    ensure => link,
    target => '/srv/leap/webapp/test/nagios/webapp_login.py'
  }


  # check syslog
  concat::fragment { 'syslog_webapp':
    source  => 'puppet:///modules/site_check_mk/agent/logwatch/syslog/webapp.cfg',
    target  => '/etc/check_mk/logwatch.d/syslog.cfg',
    order   => '02';
  }

}
