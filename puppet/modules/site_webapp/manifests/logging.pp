class site_webapp::logging {

  include site_apt::preferences::rsyslog

  rsyslog::snippet { '01-webapp':
    content => 'if $programname == "webapp" then /var/log/leap/webapp.log
stop'
  }

  augeas {
    'logrotate_webapp':
      context => '/files/etc/logrotate.d/webapp/rule',
      changes => [ 'set file /var/log/leap/webapp.log', 'set rotate 7',
                   'set schedule daily', 'set compress compress',
                   'set missingok missingok', 'set ifempty notifempty',
                   'set copytruncate copytruncate' ]
  }
}
