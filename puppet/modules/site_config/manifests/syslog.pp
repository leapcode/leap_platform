class site_config::syslog {

  include site_apt::preferences::rsyslog

  class { 'rsyslog::client':
    log_remote => false,
    log_local  => true
  }

  rsyslog::snippet { '00-anonymize_logs':
    content => '$ModLoad mmanon
action(type="mmanon" ipv4.bits="32" mode="rewrite")'
  }

  augeas {
    'logrotate_leap_deploy':
      context => '/files/etc/logrotate.d/leap_deploy/rule',
      changes => [ 'set file /var/log/leap/deploy*.log', 'set rotate 7',
                   'set schedule daily', 'set compress compress',
                   'set missingok missingok',
                   'set copytruncate copytruncate' ]
  }
}
