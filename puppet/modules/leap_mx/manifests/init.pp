class leap_mx {

  $leap_mx          = hiera('couchdb_leap_mx_user')
  $couchdb_user     = $leap_mx['username']
  $couchdb_password = $leap_mx['password']

  $couchdb_host     = 'localhost'
  $couchdb_port     = '4096'

  include soledad::common
  include site_apt::preferences::twisted

  #
  # USER AND GROUP
  #

  group { 'leap-mx':
    ensure    => present,
    allowdupe => false;
  }

  user { 'leap-mx':
    ensure    => present,
    allowdupe => false,
    gid       => 'leap-mx',
    home      => '/etc/leap',
    require   => Group['leap-mx'];
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

  #
  # LEAP-MX CODE AND DEPENDENCIES
  #

  package {
    'leap-mx':
      ensure  => latest,
      require => Class['site_apt::preferences::twisted'];

    [ 'leap-keymanager' ]:
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
