#
# make syslog log to a particular file for a particular process.
#

define leap::logfile($process=$title) {
  $logfile = "/var/log/leap/${title}.log"

  rsyslog::snippet { "50-${name}":
    content => "if \$programname startswith '${process}' then ${logfile}
&~"
  }

  augeas {
    "logrotate_${name}":
      context => "/files/etc/logrotate.d/${name}/rule",
      changes => [
        "set file ${logfile}",
        'set rotate 7',
        'set schedule daily',
        'set compress compress',
        'set missingok missingok',
        'set ifempty notifempty',
        'set copytruncate copytruncate'
      ]
  }
}
