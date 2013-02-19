class site_webapp {
  tag 'leap_service'
  $definition_files = hiera('definition_files')
  $provider         = $definition_files['provider']
  $eip_service      = $definition_files['eip_service']
  $node_domain      = hiera('domain')
  $provider_domain  = $node_domain['full_suffix']
  $webapp           = hiera('webapp')

  Class[Ruby] -> Class[rubygems] -> Class[bundler::install]

  class { 'ruby': ruby_version => '1.9.3' }

  class { 'bundler::install': install_method => 'package' }

  include rubygems
  include site_webapp::apache
  include site_webapp::couchdb
  include site_webapp::client_ca

  group { 'leap-webapp':
    ensure    => present,
    allowdupe => false;
  }

  user { 'leap-webapp':
    ensure    => present,
    allowdupe => false,
    gid       => 'leap-webapp',
    groups    => 'ssl-cert',
    home      => '/srv/leap-webapp',
    require   => [ Group['leap-webapp'] ];
  }

  file { '/srv/leap-webapp':
    ensure  => directory,
    owner   => 'leap-webapp',
    group   => 'leap-webapp',
    require => User['leap-webapp'];
  }

  vcsrepo { '/srv/leap-webapp':
    ensure   => present,
    revision => 'origin/master',
    provider => git,
    source   => 'git://code.leap.se/leap_web',
    owner    => 'leap-webapp',
    group    => 'leap-webapp',
    require  => [ User['leap-webapp'], Group['leap-webapp'] ],
    notify   => Exec['bundler_update']
  }

  exec { 'bundler_update':
    cwd     => '/srv/leap-webapp',
    command => '/bin/bash -c "/usr/bin/bundle check || /usr/bin/bundle install --path vendor/bundle"',
    unless  => '/usr/bin/bundle check',
    user    => 'leap-webapp',
    timeout => 600,
    require => [ Class['bundler::install'], Vcsrepo['/srv/leap-webapp'] ],
    notify  => Service['apache'];
  }

  exec { 'compile_assets':
    cwd     => '/srv/leap-webapp',
    command => '/bin/bash -c "/usr/bin/bundle exec rake assets:precompile"',
    user    => 'leap-webapp',
    require => Exec['bundler_update'],
    notify  => Service['apache'];
  }

  file {
    '/srv/leap-webapp/public/provider.json':
      content => $provider,
      owner   => leap-webapp, group => leap-webapp, mode => '0644';

    '/srv/leap-webapp/public/ca.crt':
      ensure  => link,
      target  => '/usr/local/share/ca-certificates/leap_api.crt';

    '/srv/leap-webapp/public/config':
      ensure => directory,
      owner  => leap-webapp, group => leap-webapp, mode => '0755';

    '/srv/leap-webapp/public/config/eip-service.json':
      content => $eip_service,
      owner   => leap-webapp, group => leap-webapp, mode => '0644';
  }

  try::file {
    '/srv/leap-webapp/public/favicon.ico':
      ensure => 'link',
      target => $webapp['favicon'];

    '/srv/leap-webapp/app/assets/stylesheets/tail.scss':
      ensure => 'link',
      target => $webapp['tail_scss'];

    '/srv/leap-webapp/app/assets/stylesheets/head.scss':
      ensure => 'link',
      target => $webapp['head_scss'];

    '/srv/leap-webapp/public/img':
      ensure => 'link',
      target => $webapp['img_dir'];
  }

  file {
    '/srv/leap-webapp/config/config.yml':
      content => template('site_webapp/config.yml.erb'),
      owner   => leap-webapp,
      group   => leap-webapp,
      mode    => '0600';
  }

  include site_shorewall::webapp

}
