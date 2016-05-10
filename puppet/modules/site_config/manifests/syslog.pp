# configure rsyslog on all nodes
class site_config::syslog {

  # only pin rsyslog packages to backports on wheezy
  case $::operatingsystemrelease {
    /^7.*/: {
      include ::site_apt::preferences::rsyslog
    }
    # on jessie+ systems, systemd and journald are enabled,
    # and journald logs IP addresses, so we need to disable
    # it until a solution is found, (#7863):
    # https://github.com/systemd/systemd/issues/2447
    default: {
      include ::journald
      augeas {
        'disable_journald':
          incl    => '/etc/systemd/journald.conf',
          lens    => 'Puppet.lns',
          changes => 'set /files/etc/systemd/journald.conf/Journal/Storage \'none\'',
          notify  => Service['systemd-journald'];
      }
    }
  }

  class { '::rsyslog::client':
    log_remote    => false,
    log_local     => true,
    custom_config => 'site_rsyslog/client.conf.erb'
  }

  rsyslog::snippet { '00-anonymize_logs':
    content => '$ModLoad mmanon
action(type="mmanon" ipv4.bits="32" mode="rewrite")'
  }

  augeas {
    'logrotate_leap_deploy':
      context => '/files/etc/logrotate.d/leap_deploy/rule',
      changes => [
        'set file /var/log/leap/deploy.log',
        'set rotate 5',
        'set size 1M',
        'set compress compress',
        'set missingok missingok',
        'set copytruncate copytruncate' ];

    # NOTE:
    # the puppet_command script requires the option delaycompress
    # be set on the summary log file.

    'logrotate_leap_deploy_summary':
      context => '/files/etc/logrotate.d/leap_deploy_summary/rule',
      changes => [
        'set file /var/log/leap/deploy-summary.log',
        'set rotate 5',
        'set size 100k',
        'set delaycompress delaycompress',
        'set compress compress',
        'set missingok missingok',
        'set copytruncate copytruncate' ]
  }
}
