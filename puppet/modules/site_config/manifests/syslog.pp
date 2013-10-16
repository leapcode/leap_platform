class site_config::syslog {

  # we need to pull in rsyslog from the leap repository until it is availbale in
  # wheezy-backports
  apt::preferences_snippet { 'fixed_rsyslog_anon_package':
    package  => 'rsyslog',
    priority => '999',
    pin      => 'release o=leap.se',
    before   => Class['rsyslog::install']
  }

  apt::preferences_snippet { 'rsyslog_anon_libestr0':
    package  => 'libestr0',
    priority => '999',
    pin      => 'release a=wheezy-backports',
    before   => Class['rsyslog::install']
  }

  class { 'rsyslog::client':
    log_remote => false,
    log_local  => true
  }

  rsyslog::snippet { '00-anonymize_logs':
    content => '$ModLoad mmanon
action(type="mmanon" ipv4.bits="32" mode="rewrite")'
  }
}
