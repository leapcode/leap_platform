class site_check_mk::agent::mx {

  file { '/usr/lib/check_mk_agent/local/check_leap_mx.sh':
    source => 'puppet:///modules/site_check_mk/agent/local_checks/mx/check_leap_mx.sh',
    mode   => '0755'
  }

}
