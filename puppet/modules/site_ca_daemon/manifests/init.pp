class site_ca_daemon {

  #$definition_files = hiera('definition_files')
  #$provider         = $definition_files['provider']
  #$eip_service      = $definition_files['eip_service']

  Class[Ruby] -> Class[rubygems] -> Class[bundler::install]

  class { 'ruby': ruby_version => '1.9.3' }

  class { 'bundler::install': install_method => 'package' }

  include rubygems
  #include site_ca_daemon::apache
  include site_ca_daemon::couchdb

  group { 'leap_ca_daemon':
    ensure    => present,
    allowdupe => false;
  }

  user { 'leap_ca_daemon':
    ensure    => present,
    allowdupe => false,
    gid       => 'leap_ca_daemon',
    home      => '/srv/leap_ca_daemon',
    require   => [ Group['leap_ca_daemon'] ];
  }

  file { '/srv/leap_ca_daemon':
    ensure  => directory,
    owner   => 'leap_ca_daemon',
    group   => 'leap_ca_daemon',
    require => User['leap_ca_daemon'];
  }

  vcsrepo { '/srv/leap_ca_daemon':
    ensure   => present,
    revision => 'origin/deploy',
    provider => git,
    source   => 'git://code.leap.se/leap_ca',
    owner    => 'leap_ca_daemon',
    group    => 'leap_ca_daemon',
    require  => [ User['leap_ca_daemon'], Group['leap_ca_daemon'] ],
    notify   => Exec['bundler_update']
  }

  exec { 'bundler_update':
    cwd     => '/srv/leap_ca_daemon',
    command => '/bin/bash -c "/usr/bin/bundle check || /usr/bin/bundle install"',
    unless  => '/usr/bin/bundle check',
    require => [ Class['bundler::install'], Vcsrepo['/srv/leap_ca_daemon'] ];
  }

}
