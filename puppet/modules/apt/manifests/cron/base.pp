class apt::cron::base {

  package { 'cron-apt': ensure => installed }

  case $apt_cron_hours {
    '': {}
    default: {
      # cron-apt defaults to run every night at 4 o'clock
      # so we try not to run at the same time.
      cron { 'apt_cron_every_N_hours':
        command => 'test -x /usr/sbin/cron-apt && /usr/sbin/cron-apt',
        user    => root,
        hour    => "${apt_cron_hours}",
        minute  => 10,
        require => Package['cron-apt'],
      }
    }
  }

}
