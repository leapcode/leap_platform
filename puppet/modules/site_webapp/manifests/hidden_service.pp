class site_webapp::hidden_service {
  $tor              = hiera('tor')
  $hidden_service   = $tor['hidden_service']
  $tor_domain       = "${hidden_service['address']}.onion"

  include site_apache::common
  include apache::module::headers
  include apache::module::alias
  include apache::module::expires
  include apache::module::removeip
  include apache::module::status

  include tor::daemon
  tor::daemon::hidden_service { 'webapp': ports => '80 127.0.0.1:80' }

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
      mode    => '0600';

    '/var/lib/tor/webapp/hostname':
      ensure  => present,
      content => $tor_domain,
      owner   => 'debian-tor',
      group   => 'debian-tor',
      mode    => '0600';

    '/etc/apache2/mods-enabled/status.conf':
      ensure => absent,
      notify => Service['apache'];
  }

  apache::vhost::file {
    'hidden_service':
      content => template('site_apache/vhosts.d/hidden_service.conf.erb');
    'server_status':
      vhost_source => 'modules/site_webapp/server-status.conf';
  }

  include site_shorewall::tor
}
