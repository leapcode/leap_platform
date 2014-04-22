class site_check_mk::agent::mx {

  # watch logs
  file { '/etc/check_mk/logwatch.d/leap_mx.cfg':
    source => 'puppet:///modules/site_check_mk/agent/logwatch/leap_mx.cfg',
  }

  # local nagios plugin checks via mrpe
  file_line {
    'Leap_MX_Procs':
      line => 'Leap_MX_Procs  /usr/lib/nagios/plugins/check_procs -w 1:1 -c 1:1 -a leap_mx',
      path => '/etc/check_mk/mrpe.cfg';
  }


  # check stale files in queue dir
  file { '/usr/lib/check_mk_agent/local/check_leap_mx.sh':
    source  => 'puppet:///modules/site_check_mk/agent/local_checks/mx/check_leap_mx.sh',
    mode    => '0755',
    require => Package['check_mk-agent']
  }

}
