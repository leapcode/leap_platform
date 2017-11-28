# deploy static service
class site_static {
  tag 'leap_service'

  include site_config::default
  include site_config::x509::cert
  include site_config::x509::key
  include site_config::x509::ca_bundle

  $services  = hiera('services', [])
  $static    = hiera('static')
  $domains   = $static['domains']
  $formats   = $static['formats']
  $bootstrap = $static['bootstrap_files']
  $tor       = hiera('tor', false)
  if $tor and member($services, 'tor_hidden_service') {
    $onion_active = true
  } else {
    $onion_active = false
  }

  file {
    '/srv/static/':
      ensure => 'directory',
      owner  => 'root',
      group  => 'root',
      mode   => '0744';
    '/srv/static/public':
      ensure => 'directory',
      owner  => 'root',
      group  => 'root',
      mode   => '0744';
  }

  if $bootstrap['enabled'] {
    $bootstrap_domain  = $bootstrap['domain']
    $bootstrap_client  = $bootstrap['client_version']
    file { '/srv/static/public/provider.json':
      content => $bootstrap['provider_json'],
      owner   => 'www-data',
      group   => 'www-data',
      mode    => '0444',
      notify  => Service[apache];
    }
    # It is important to always touch provider.json: the client needs to check x-min-client-version header,
    # but this is only sent when the file has been modified (otherwise 304 is sent by apache). The problem
    # is that changing min client version won't alter the content of provider.json, so we must touch it.
    exec { '/bin/touch /srv/static/public/provider.json':
      require => File['/srv/static/public/provider.json'];
    }
  }

  include apache::module::headers
  include apache::module::alias
  include apache::module::expires
  include apache::module::removeip
  include apache::module::dir
  include apache::module::negotiation
  include site_apache::common
  include site_config::ruby::dev

  if (member($formats, 'rack')) {
    class { 'passenger':
      manage_munin => false,
    }
  }

  if (member($formats, 'amber')) {
    rubygems::gem{'amber-0.3.8':
      require =>  Package['zlib1g-dev']
    }

    package { 'zlib1g-dev':
      ensure => installed
    }
  }

  if $onion_active {
    $hidden_service = $tor['hidden_service']
    $onion_domain     = "${hidden_service['address']}.onion"
    class { 'site_static::hidden_service':
      single_hop => $hidden_service['single_hop'],
      v3         => $hidden_service['v3']
    }

    # Currently, we only support a single hidden service address per server.
    # So if there is more than one domain configured, then we need to make sure
    # we don't enable the hidden service for every domain.
    if size(keys($domains)) == 1 {
      $always_use_hidden_service = true
    } else {
      $always_use_hidden_service = false
    }
  }

  create_resources(site_static::domain, $domains)

  include site_shorewall::defaults
  include site_shorewall::service::http
  include site_shorewall::service::https
}
