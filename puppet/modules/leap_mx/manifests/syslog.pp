class leap_mx::syslog {

  rsyslog::snippet { '99-leap-mx':
    content => 'if $programname startswith \'leap-mx\' then /var/log/leap/mx.log
&~'
  }

  augeas {
    'logrotate_leap-mx':
      context => '/files/etc/logrotate.d/leap-mx/rule',
      changes => [ 'set file /var/log/leap/mx*.log', 'set rotate 7',
                   'set schedule daily', 'set compress compress',
                   'set missingok missingok', 'set ifempty notifempty',
                   'set copytruncate copytruncate' ]
  }

}
