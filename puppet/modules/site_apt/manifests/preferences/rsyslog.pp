class site_apt::preferences::rsyslog {

  apt::preferences_snippet { 'rsyslog_anon_depends':
    package  => 'libestr0 librelp0 rsyslog*',
    priority => '999',
    pin      => 'release a=wheezy-backports',
    before   => Class['rsyslog::install']
  }
}
