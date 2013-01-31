class site_ca_daemon {
  tag 'service'
  #$definition_files = hiera('definition_files')
  #$provider         = $definition_files['provider']
  #$eip_service      = $definition_files['eip_service']
  $x509             = hiera('x509')

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


  x509::key {
    'leap_ca_daemon':
      content => $x509['ca_key'];
      #notify  => Service['leap_ca_daemon']; <== no service yet for leap_ca_daemon
  }

  x509::cert {
    'leap_ca_daemon':
      content => $x509['ca_cert'];
      #notify  => Service['leap_ca_daemon'];  <== no service yet for leap_ca_daemon
  }

  #
  # Does CA need a server key/cert? I think not now.
  #
  # x509::key {
  #   'server':
  #     content => $x509['key'];
  # }
  #
  # x509::cert {
  #   'server':
  #     content => $x509['cert'];
  # }

  # x509::ca {
  #   'leap_ca_daemon':
  #     content => $x509['ca_cert'];
  # }


  file { '/srv/leap_ca_daemon':
    ensure  => directory,
    owner   => 'leap_ca_daemon',
    group   => 'leap_ca_daemon',
    require => User['leap_ca_daemon'];
  }

  vcsrepo { '/srv/leap_ca_daemon':
    ensure   => present,
    revision => 'origin/master',
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

  file { '/usr/local/bin/leap_ca_daemon':
    ensure => link,
    target => '/srv/leap_ca_daemon/bin/leap_ca_daemon',
  }

  file { '/etc/cron.hourly/leap_ca':
    ensure  => present,
    content => "#/bin/sh\n/srv/leap_ca_daemon/bin/leap_ca_daemon --run-once > /dev/null",
    owner   => 'root',
    group   => 0,
    mode    => '0755',
  }


}
