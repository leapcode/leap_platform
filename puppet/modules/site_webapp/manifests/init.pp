class site_webapp {

  Class[Ruby] -> Class[rubygems] -> Class[bundler::install]

  class { 'ruby': ruby_version => '1.9.3' }

  include rubygems

  class { 'bundler::install': install_method => '' }

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
    revision => 'develop',
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
}


