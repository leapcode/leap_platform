class site_check_mk::agent::webapp {

  # remove leftovers of webapp python checks
  file {
    [ '/usr/lib/check_mk_agent/local/nagios-webapp_login.py',
      '/usr/lib/check_mk_agent/local/soledad_sync.py' ]:
    ensure  => absent
  }

  # check syslog
  concat::fragment { 'syslog_webapp':
    source  => 'puppet:///modules/site_check_mk/agent/logwatch/syslog/webapp.cfg',
    target  => '/etc/check_mk/logwatch.d/syslog.cfg',
    order   => '02';
  }

}
