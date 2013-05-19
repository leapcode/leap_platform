#
# TODO: currently, this is dependent on the HAProxy stuff that is in site_webapp.
# it would be good to factor that out into a site_haproxy, so that nickserver could be applied independently.
#

class site_nickserver {
  tag 'leap_service'
  include site_config::ruby

  #
  # VARIABLES
  #

  $nickserver        = hiera('nickserver')
  $nickserver_port   = $nickserver['port']
  $couchdb_user      = $nickserver['couchdb_user']['username']
  $couchdb_password  = $nickserver['couchdb_user']['password']
  $couchdb_host      = 'localhost'    # couchdb is available on localhost via haproxy, which is bound to 4096.
  $couchdb_port      = '4096'         # See site_webapp/templates/haproxy_couchdb.cfg.erg

  #
  # USER AND GROUP
  #

  group { 'nickserver':
    ensure    => present,
    allowdupe => false;
  }
  user { 'nickserver':
    ensure    => present,
    allowdupe => false,
    gid       => 'nickserver',
    groups    => 'ssl-cert',
    home      => '/srv/leap/nickserver',
    require   => Group['nickserver'];
  }

  #
  # NICKSERVER CODE
  #

  # libssl-dev must be installed before eventmachine gem in order to support TLS
  package {
    'libssl-dev': ensure => installed;
  }
  vcsrepo { '/srv/leap/nickserver':
    ensure   => present,
    revision => 'origin/master',
    provider => git,
    source   => 'git://code.leap.se/nickserver',
    owner    => 'nickserver',
    group    => 'nickserver',
    require  => [ User['nickserver'], Group['nickserver'] ],
    notify   => Exec['nickserver_bundler_update'];
  }
  exec { 'nickserver_bundler_update':
    cwd     => '/srv/leap/nickserver',
    command => '/bin/bash -c "/usr/bin/bundle check || /usr/bin/bundle install --path vendor/bundle"',
    unless  => '/usr/bin/bundle check',
    user    => 'nickserver',
    timeout => 600,
    require => [ Class['bundler::install'], Vcsrepo['/srv/leap/nickserver'], Package['libssl-dev'] ],
    notify  => Service['nickserver'];
  }

  #
  # NICKSERVER CONFIG
  #

  file { '/etc/leap/nickserver.yml':
    content => template('site_nickserver/nickserver.yml.erb'),
    owner   => nickserver,
    group   => nickserver,
    mode    => '0600',
    notify  => Service['nickserver'];
  }

  #
  # NICKSERVER DAEMON
  #

  file {
    '/usr/bin/nickserver':
      ensure  => link,
      target  => '/srv/leap/nickserver/bin/nickserver',
      require => Vcsrepo['/srv/leap/nickserver'];
    '/etc/init.d/nickserver':
      owner   => root, group => 0, mode => '0755',
      source  => '/srv/leap/nickserver/dist/debian-init-script',
      require => Vcsrepo['/srv/leap/nickserver'];
  }

  service { 'nickserver':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => File['/etc/init.d/nickserver'];
  }

  #
  # FIREWALL
  #

  file { '/etc/shorewall/macro.nickserver':
    content => "PARAM   -       -       tcp    $nickserver_port",
    notify  => Service['shorewall'],
    require => Package['shorewall'];
  }

  shorewall::rule { 'net2fw-nickserver':
    source      => 'net',
    destination => '$FW',
    action      => 'nickserver(ACCEPT)',
    order       => 200;
  }

}