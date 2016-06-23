# Configure tor hidden service for webapp
class site_webapp::hidden_service {
  $tor              = hiera('tor')
  $hidden_service   = $tor['hidden_service']
  $tor_domain       = "${hidden_service['address']}.onion"

  include site_apache::common
  include apache::module::headers
  include apache::module::alias
  include apache::module::expires
  include apache::module::removeip

  include tor::daemon
  tor::daemon::hidden_service { 'webapp': ports => [ '80 127.0.0.1:80'] }

  file {
    '/var/lib/tor/webapp/':
      ensure  => directory,
      owner   => 'debian-tor',
      group   => 'debian-tor',
      mode    => '2700';

    '/var/lib/tor/webapp/private_key':
      ensure  => present,
      source  => "/srv/leap/files/nodes/${::hostname}/tor.key",
      owner   => 'debian-tor',
      group   => 'debian-tor',
      mode    => '0600',
      notify  => Service['tor'];

    '/var/lib/tor/webapp/hostname':
      ensure  => present,
      content => $tor_domain,
      owner   => 'debian-tor',
      group   => 'debian-tor',
      mode    => '0600',
      notify  => Service['tor'];
  }

  # it is necessary to zero out the config of the status module
  # because we are configuring our own version that is unavailable
  # over the hidden service (see: #7456 and #7776)
  apache::module { 'status': ensure => present, conf_content => ' ' }
  # the access_compat module is required to enable Allow directives
  apache::module { 'access_compat': ensure => present }

  apache::vhost::file {
    'hidden_service':
      content => template('site_apache/vhosts.d/hidden_service.conf.erb');
    'server_status':
      vhost_source => 'modules/site_webapp/server-status.conf';
  }

  include site_shorewall::tor
}
