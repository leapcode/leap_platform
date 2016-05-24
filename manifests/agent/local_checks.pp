class check_mk::agent::local_checks{
  file { '/usr/lib/check_mk_agent/local':
    ensure  => directory,
    source  => [
      'puppet:///modules/site_check_mk/agent/local_checks/all_hosts',
      'puppet:///modules/check_mk/agent/local_checks/all_hosts' ],
    recurse => true,
    require => Package['check_mk-agent'],
  }

}
