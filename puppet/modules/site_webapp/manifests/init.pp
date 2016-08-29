# configure webapp service
class site_webapp {
  tag 'leap_service'
  $definition_files = hiera('definition_files')
  $provider         = $definition_files['provider']
  $eip_service      = $definition_files['eip_service']
  $soledad_service  = $definition_files['soledad_service']
  $smtp_service     = $definition_files['smtp_service']
  $node_domain      = hiera('domain')
  $provider_domain  = $node_domain['full_suffix']
  $webapp           = hiera('webapp')
  $api_version      = $webapp['api_version']
  $secret_token     = $webapp['secret_token']
  $tor              = hiera('tor', false)
  $sources          = hiera('sources')

  Class['site_config::default'] -> Class['site_webapp']

  include ::site_config::ruby::dev
  include ::site_webapp::apache
  include ::site_webapp::couchdb
  include ::site_haproxy
  include ::site_webapp::cron
  include ::site_config::default
  include ::site_config::x509::cert
  include ::site_config::x509::key
  include ::site_config::x509::ca
  include ::site_config::x509::client_ca::ca
  include ::site_config::x509::client_ca::key
  include ::site_nickserver
  include ::site_apt::preferences::twisted

  # remove leftovers from previous installations on webapp nodes
  include ::site_config::remove::webapp

  group { 'leap-webapp':
    ensure    => present,
    allowdupe => false;
  }

  user { 'leap-webapp':
    ensure    => present,
    allowdupe => false,
    gid       => 'leap-webapp',
    groups    => 'ssl-cert',
    home      => '/srv/leap/webapp',
    require   => [ Group['leap-webapp'] ];
  }

  vcsrepo { '/srv/leap/webapp':
    ensure   => present,
    force    => true,
    revision => $sources['webapp']['revision'],
    provider => $sources['webapp']['type'],
    source   => $sources['webapp']['source'],
    owner    => 'leap-webapp',
    group    => 'leap-webapp',
    require  => [ User['leap-webapp'], Group['leap-webapp'] ],
    notify   => Exec['bundler_update']
  }

  exec { 'bundler_update':
    cwd     => '/srv/leap/webapp',
    command => '/bin/bash -c "/usr/bin/bundle check --path vendor/bundle || /usr/bin/bundle install --path vendor/bundle --without test development debug"',
    unless  => '/usr/bin/bundle check --path vendor/bundle',
    user    => 'leap-webapp',
    timeout => 600,
    require => [
      Class['bundler::install'],
      Vcsrepo['/srv/leap/webapp'],
      Class['site_config::ruby::dev'],
      Service['shorewall'] ],
    notify  => Service['apache'];
  }

  #
  # NOTE: in order to support a webapp that is running on a subpath and not the
  # root of the domain assets:precompile needs to be run with
  # RAILS_RELATIVE_URL_ROOT=/application-root
  #

  exec { 'compile_assets':
    cwd       => '/srv/leap/webapp',
    command   => '/bin/bash -c "RAILS_ENV=production /usr/bin/bundle exec rake assets:precompile"',
    user      => 'leap-webapp',
    logoutput => on_failure,
    require   => Exec['bundler_update'],
    notify    => Service['apache'];
  }

  file {
    '/srv/leap/webapp/config/provider':
      ensure  => directory,
      require => Vcsrepo['/srv/leap/webapp'],
      owner   => leap-webapp, group => leap-webapp, mode => '0755';

    '/srv/leap/webapp/config/provider/provider.json':
      content => $provider,
      require => Vcsrepo['/srv/leap/webapp'],
      owner   => leap-webapp, group => leap-webapp, mode => '0644';

    '/srv/leap/webapp/public/ca.crt':
      ensure  => link,
      require => Vcsrepo['/srv/leap/webapp'],
      target  => "${x509::variables::local_CAs}/${site_config::params::ca_name}.crt";

    "/srv/leap/webapp/public/${api_version}":
      ensure  => directory,
      require => Vcsrepo['/srv/leap/webapp'],
      owner   => leap-webapp, group => leap-webapp, mode => '0755';

    "/srv/leap/webapp/public/${api_version}/config/":
      ensure  => directory,
      require => Vcsrepo['/srv/leap/webapp'],
      owner   => leap-webapp, group => leap-webapp, mode => '0755';

    "/srv/leap/webapp/public/${api_version}/config/eip-service.json":
      content => $eip_service,
      require => Vcsrepo['/srv/leap/webapp'],
      owner   => leap-webapp, group => leap-webapp, mode => '0644';

    "/srv/leap/webapp/public/${api_version}/config/soledad-service.json":
      content => $soledad_service,
      require => Vcsrepo['/srv/leap/webapp'],
      owner   => leap-webapp, group => leap-webapp, mode => '0644';

    "/srv/leap/webapp/public/${api_version}/config/smtp-service.json":
      content => $smtp_service,
      require => Vcsrepo['/srv/leap/webapp'],
      owner   => leap-webapp, group => leap-webapp, mode => '0644';
  }

  try::file {
    '/srv/leap/webapp/config/customization':
      ensure  => directory,
      recurse => true,
      purge   => true,
      force   => true,
      owner   => leap-webapp,
      group   => leap-webapp,
      mode    => 'u=rwX,go=rX',
      require => Vcsrepo['/srv/leap/webapp'],
      notify  => Exec['compile_assets'],
      source  => $webapp['customization_dir'];
  }

  git::changes {
    'public/favicon.ico':
      cwd     => '/srv/leap/webapp',
      require => Vcsrepo['/srv/leap/webapp'],
      user    => 'leap-webapp';
  }

  file {
    '/srv/leap/webapp/config/config.yml':
      content => template('site_webapp/config.yml.erb'),
      owner   => leap-webapp,
      group   => leap-webapp,
      mode    => '0600',
      require => Vcsrepo['/srv/leap/webapp'],
      notify  => Service['apache'];
  }

  if $tor {
    $hidden_service = $tor['hidden_service']
    if $hidden_service['active'] {
      include ::site_webapp::hidden_service
    }
  }


  # needed for the soledad-sync check which is run on the
  # webapp node
  include ::soledad::client

  leap::logfile { 'webapp': }

  include ::site_shorewall::webapp
  include ::site_check_mk::agent::webapp
}
