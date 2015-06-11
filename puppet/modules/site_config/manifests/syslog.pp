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
      changes => [ 'set file /var/log/leap/deploy.log',
                   'set rotate 5',
                   'set size 1M',
                   'set compress compress',
                   'set missingok missingok',
                   'set copytruncate copytruncate' ];

    # NOTE:
    # the puppet_command script requires the option delaycompress
    # be set on the summary log file.

    'logrotate_leap_deploy_summary':
      context => '/files/etc/logrotate.d/leap_deploy_summary/rule',
      changes => [ 'set file /var/log/leap/deploy-summary.log',
                   'set rotate 5',
                   'set size 100k',
                   'set delaycompress delaycompress',
                   'set compress compress',
                   'set missingok missingok',
                   'set copytruncate copytruncate' ]
  }
}
