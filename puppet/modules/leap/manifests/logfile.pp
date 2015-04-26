#
# make syslog log to a particular file for a particular process.
#

define leap::logfile($process=$name) {
  $logfile = "/var/log/leap/${name}.log"

  rsyslog::snippet { "50-${name}":
    content => template('leap/rsyslog.erb')
  }

  augeas {
    "logrotate_${name}":
      context => "/files/etc/logrotate.d/${name}/rule",
      changes => [
        "set file ${logfile}",
        'set rotate 5',
        'set schedule daily',
        'set compress compress',
        'set missingok missingok',
        'set ifempty notifempty',
        'set copytruncate copytruncate'
      ]
  }
}
