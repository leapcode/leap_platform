class site_nagios::client {
  package { [ 'check-mk-agent', 'check-mk-agent-logwatch' ]:
    ensure => installed,
  }
}
