class site_config::syslog {

  apt::preferences_snippet { 'rsyslog_anon_depends':
    package  => 'libestr0 librelp0 rsyslog*',
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
