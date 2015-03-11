class site_check_mk::agent::mx {

  # watch logs
  file { '/etc/check_mk/logwatch.d/leap_mx.cfg':
    source => 'puppet:///modules/site_check_mk/agent/logwatch/leap_mx.cfg',
  }

  # local nagios plugin checks via mrpe
  augeas {
    'Leap_MX_Procs':
      incl    => '/etc/check_mk/mrpe.cfg',
      lens    => 'Spacevars.lns',
      changes => [
        'rm /files/etc/check_mk/mrpe.cfg/Leap_MX_Procs',
        'set Leap_MX_Procs \'/usr/lib/nagios/plugins/check_procs -w 1:1 -c 1:1 -a "/usr/bin/python /usr/bin/twistd --pidfile=/var/run/leap_mx.pid --rundir=/var/lib/leap_mx/ --python=/usr/share/app/leap_mx.tac --logfile=/var/log/leap_mx.log"\'' ];
  }

  # check stale files in queue dir
  file { '/usr/lib/check_mk_agent/local/check_leap_mx.sh':
    source  => 'puppet:///modules/site_check_mk/agent/local_checks/mx/check_leap_mx.sh',
    mode    => '0755',
    require => Package['check_mk-agent']
  }

}
