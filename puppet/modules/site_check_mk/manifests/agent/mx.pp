# check check_mk agent checks for mx service
class site_check_mk::agent::mx {

  # watch logs
  file { '/etc/check_mk/logwatch.d/leap_mx.cfg':
    source => 'puppet:///modules/site_check_mk/agent/logwatch/leap_mx.cfg',
  }

  # local nagios plugin checks via mrpe
  # removed because leap_cli integrates a check for running mx procs already,
  # which is also integrated into nagios (called "Mx/Are_MX_daemons_running")
  augeas {
    'Leap_MX_Procs':
      incl    => '/etc/check_mk/mrpe.cfg',
      lens    => 'Spacevars.lns',
      changes => 'rm /files/etc/check_mk/mrpe.cfg/Leap_MX_Procs',
      require => File['/etc/check_mk/mrpe.cfg'];
  }

  # check stale files in queue dir
  file { '/usr/lib/check_mk_agent/local/check_leap_mx.sh':
    source  => 'puppet:///modules/site_check_mk/agent/local_checks/mx/check_leap_mx.sh',
    mode    => '0755',
    require => Package['check_mk-agent']
  }

}
