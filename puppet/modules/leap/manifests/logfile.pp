#
# make syslog log to a particular file for a particular process.
#
# arguments:
#
#   * name: what config files are named as (eg.  /etc/rsyslog.d/50-$name.conf)
#   * log: the full path of the log file (defaults to /var/log/leap/$name.log
#   * process: the syslog tag to filter on (defaults to name)
#
define leap::logfile($process = $name, $log = undef) {
  if $log {
    $logfile = $log
  } else {
    $logfile = "/var/log/leap/${name}.log"
  }

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
