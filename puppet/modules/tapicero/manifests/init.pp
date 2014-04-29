class tapicero {
  tag 'leap_service'

  $couchdb                 = hiera('couch')
  $couchdb_port            = $couchdb['port']

  $couchdb_users           = $couchdb['users']

  $couchdb_admin_user      = $couchdb_users['admin']['username']
  $couchdb_admin_password  = $couchdb_users['admin']['password']

  $couchdb_soledad_user    = $couchdb_users['soledad']['username']
  $couchdb_leap_mx_user    = $couchdb_users['leap_mx']['username']


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

    ##
    ## TAPICERO DIRECTORIES
    ##

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

    ##
    ## TAPICERO CONFIG
    ##

    '/etc/leap/tapicero.yaml':
      content => template('tapicero/tapicero.yaml.erb'),
      owner   => 'tapicero',
      group   => 'tapicero',
      mode    => '0600',
      notify  => Service['tapicero'];

    ##
    ## TAPICERO INIT
    ##

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
    revision => 'origin/master',
    provider => git,
    source   => 'https://leap.se/git/tapicero',
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
    hasstatus  => true,
    hasrestart => true,
    require    => [ File['/etc/init.d/tapicero'], File['/var/run/tapicero'] ];
  }

}
