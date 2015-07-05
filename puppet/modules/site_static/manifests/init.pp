class site_static {
  tag 'leap_service'

  include site_config::x509::cert
  include site_config::x509::key
  include site_config::x509::ca_bundle

  $static        = hiera('static')
  $domains       = $static['domains']
  $formats       = $static['formats']
  $bootstrap     = $static['bootstrap_files']

  if $bootstrap['enabled'] {
    $bootstrap_domain  = $bootstrap['domain']
    $bootstrap_client  = $bootstrap['client_version']
    file { '/srv/leap/provider.json':
      content => $bootstrap['provider_json'],
      owner   => 'www-data',
      group   => 'www-data',
      mode    => '0444';
    }
    # It is important to always touch provider.json: the client needs to check x-min-client-version header,
    # but this is only sent when the file has been modified (otherwise 304 is sent by apache). The problem
    # is that changing min client version won't alter the content of provider.json, so we must touch it.
    exec { '/bin/touch /srv/leap/provider.json':
      require => File['/srv/leap/provider.json'];
    }
  }

  class { '::apache': no_default_site => true, ssl => true }
  include site_apache::module::headers
  include site_apache::module::alias
  include site_apache::module::expires
  include site_apache::module::removeip
  include site_apache::module::rewrite
  apache::config::include{ 'ssl_common.inc': }

  include site_config::ruby::dev

  if (member($formats, 'rack')) {
    include site_apt::preferences::passenger
    class { 'passenger':
      use_munin => false,
      require   => Class['site_apt::preferences::passenger']
    }
  }

  if (member($formats, 'amber')) {
    package { 'zlib1g-dev':
      ensure => installed
    }
    rubygems::gem{'amber-0.3.4': }
  }

  create_resources(site_static::domain, $domains)

  include site_shorewall::defaults
  include site_shorewall::service::http
  include site_shorewall::service::https
}
