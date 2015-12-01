class leap_mx {

  $leap_mx          = hiera('couchdb_leap_mx_user')
  $couchdb_user     = $leap_mx['username']
  $couchdb_password = $leap_mx['password']

  $couchdb_host     = 'localhost'
  $couchdb_port     = '4096'

  $sources          = hiera('sources')

  include soledad::common
  include site_apt::preferences::twisted

  #
  # USER AND GROUP
  #
  # Make the user for leap-mx. This user is where all legitimate, non-system
  # mail is delivered so leap-mx can process it. Previously, we let the system
  # pick a uid/gid, but we need to know what they are set to in order to set the
  # virtual_uid_maps and virtual_gid_maps. Its a bit overkill write a fact just
  # for this, so instead we pick arbitrary numbers that seem unlikely to be used
  # and then use them in the postfix configuration

  group { 'leap-mx':
    ensure    => present,
    gid       => 42424,
    allowdupe => false;
  }

  user { 'leap-mx':
    ensure     => present,
    comment    => 'Leap Mail',
    allowdupe  => false,
    uid        => 42424,
    gid        => 'leap-mx',
    home       => '/var/mail/leap-mx',
    shell      => '/bin/false',
    managehome => true,
    require    => Group['leap-mx'];
  }

  #
  # LEAP-MX CONFIG
  #

  file { '/etc/leap/mx.conf':
    content => template('leap_mx/mx.conf.erb'),
    owner   => 'leap-mx',
    group   => 'leap-mx',
    mode    => '0600',
    notify  => Service['leap-mx'];
  }

  leap::logfile { 'mx': }

  #
  # LEAP-MX CODE AND DEPENDENCIES
  #

  package {
    $sources['leap-mx']['package']:
      ensure  => $sources['leap-mx']['revision'],
      require => [
        Class['site_apt::preferences::twisted'],
        Class['site_apt::leap_repo'],
        User['leap-mx'] ];

    'leap-keymanager':
      ensure => latest;
  }

  #
  # LEAP-MX DAEMON
  #

  service { 'leap-mx':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => [ Package['leap-mx'] ];
  }
}
