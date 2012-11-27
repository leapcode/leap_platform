class site_webapp {

  $definition_files = hiera('definition_files')
  $provider         = $definition_files['provider']

  Class[Ruby] -> Class[rubygems] -> Class[bundler::install]

  class { 'ruby': ruby_version => '1.9.3' }

  class { 'bundler::install': install_method => '' }

  include rubygems
  include site_webapp::apache

  group { 'leap-webapp':
    ensure    => present,
    allowdupe => false;
  }

  user { 'leap-webapp':
    ensure    => present,
    allowdupe => false,
    gid       => 'leap-webapp',
    home      => '/srv/leap-webapp',
    require   => [ Group['leap-webapp'] ];
  }

  file { '/srv/leap-webapp':
    ensure  => present,
    owner   => 'leap-webapp',
    group   => 'leap-webapp',
    require => User['leap-webapp'];
  }

  vcsrepo { '/srv/leap-webapp':
    ensure   => present,
    revision => 'origin/develop',
    provider => git,
    source   => 'git://code.leap.se/leap_web',
    owner    => 'leap-webapp',
    group    => 'leap-webapp',
    require  => [ User['leap-webapp'], Group['leap-webapp'] ],
    notify   => Exec['bundler_update']
  }

  exec { 'bundler_update':
    cwd     => '/srv/leap-webapp',
    command => '/bin/bash -c "/usr/bin/bundle check || /usr/bin/bundle install"',
    unless  => '/usr/bin/bundle check',
    require => [ Class['bundler::install'], Vcsrepo['/srv/leap-webapp'] ];
  }

  file {
    '/srv/leap-webapp/public/provider.json':
      content => $provider,
      owner   => leap-webapp, group => leap-webapp, mode => '0644';

    '/srv/leap-webapp/public/ca.crt':
      content => $cert_root,
      owner   => leap-webapp, group => leap-webapp, mode => '0644';
  }

}
