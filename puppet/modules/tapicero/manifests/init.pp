class tapicero {
  tag 'leap_service'

  $couchdb                 = hiera('couch')
  $couchdb_port            = $couchdb['port']

  $couchdb_users           = $couchdb['users']

  $couchdb_admin_user      = $couchdb_users['admin']['username']
  $couchdb_admin_password  = $couchdb_users['admin']['password']

  $couchdb_soledad_user    = $couchdb_users['soledad']['username']
  $couchdb_leap_mx_user    = $couchdb_users['leap_mx']['username']

  $couchdb_mode            = $couchdb['mode']
  $couchdb_replication     = $couchdb['replication']

  $sources                 = hiera('sources')

  Class['site_config::default'] -> Class['tapicero']

  include site_config::ruby::dev

  #
  # USER AND GROUP
  #

  group { 'tapicero':
    ensure    => present,
    allowdupe => false;
  }

  user { 'tapicero':
    ensure    => present,
    allowdupe => false,
    gid       => 'tapicero',
    home      => '/srv/leap/tapicero',
    require   => Group['tapicero'];
  }

  #
  # TAPICERO FILES
  #

  file {

    #
    # TAPICERO DIRECTORIES
    #

    '/srv/leap/tapicero':
      ensure  => directory,
      owner   => 'tapicero',
      group   => 'tapicero',
      require => User['tapicero'];

    '/var/lib/leap/tapicero':
      ensure  => directory,
      owner   => 'tapicero',
      group   => 'tapicero',
      require => User['tapicero'];

    # for pid file
    '/var/run/tapicero':
      ensure  => directory,
      owner   => 'tapicero',
      group   => 'tapicero',
      require => User['tapicero'];

    #
    # TAPICERO CONFIG
    #

    '/etc/leap/tapicero.yaml':
      content => template('tapicero/tapicero.yaml.erb'),
      owner   => 'tapicero',
      group   => 'tapicero',
      mode    => '0600',
      notify  => Service['tapicero'];

    #
    # TAPICERO INIT
    #

    '/etc/init.d/tapicero':
      source  => 'puppet:///modules/tapicero/tapicero.init',
      owner   => root,
      group   => 0,
      mode    => '0755',
      require => Vcsrepo['/srv/leap/tapicero'];
  }

  #
  # TAPICERO CODE
  #

  vcsrepo { '/srv/leap/tapicero':
    ensure   => present,
    force    => true,
    revision => $sources['tapicero']['revision'],
    provider => $sources['tapicero']['type'],
    source   => $sources['tapicero']['source'],
    owner    => 'tapicero',
    group    => 'tapicero',
    require  => [ User['tapicero'], Group['tapicero'] ],
    notify   => Exec['tapicero_bundler_update']
  }

  exec { 'tapicero_bundler_update':
    cwd     => '/srv/leap/tapicero',
    command => '/bin/bash -c "/usr/bin/bundle check || /usr/bin/bundle install --path vendor/bundle --without test development"',
    unless  => '/usr/bin/bundle check',
    user    => 'tapicero',
    timeout => 600,
    require => [
                Class['bundler::install'],
                Vcsrepo['/srv/leap/tapicero'],
                Class['site_config::ruby::dev'] ],
    notify  => Service['tapicero'];
  }

  #
  # TAPICERO DAEMON
  #

  service { 'tapicero':
    ensure     => running,
    enable     => true,
    hasstatus  => false,
    hasrestart => true,
    require    => [ File['/etc/init.d/tapicero'],
                    File['/var/run/tapicero'],
                    Couchdb::Add_user[$::site_couchdb::couchdb_tapicero_user] ];
  }

  rsyslog::snippet { '99-tapicero':
    content => 'if $programname startswith \'tapicero\' then /var/log/leap/tapicero.log
&~'
  }

  augeas {
    'logrotate_tapicero':
      context => '/files/etc/logrotate.d/tapicero/rule',
      changes => [ 'set file /var/log/leap/tapicero*.log', 'set rotate 7',
                   'set schedule daily', 'set compress compress',
                   'set missingok missingok', 'set ifempty notifempty',
                   'set copytruncate copytruncate' ]
  }
}
