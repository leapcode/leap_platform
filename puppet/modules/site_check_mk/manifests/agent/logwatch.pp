class site_check_mk::agent::logwatch {
  # Deploy mk_logwatch 1.2.4 so we can split the config
  # into multiple config files in /etc/check_mk/logwatch.d
  # see https://leap.se/code/issues/5135

  file { '/usr/lib/check_mk_agent/plugins/mk_logwatch':
    source => 'puppet:///modules/site_check_mk/agent/plugins/mk_logwatch.1.2.4',
    mode   => '0755'
  }

}
