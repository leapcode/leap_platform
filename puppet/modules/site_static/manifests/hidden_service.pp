# create hidden service for static sites
class site_static::hidden_service ( $single_hop = false, $v3 = false ) {
  Class['site_tor::hidden_service'] -> Class['site_static::hidden_service']
  include site_tor::hidden_service

  tor::daemon::hidden_service { 'static':
    ports      => [ '80 127.0.0.1:80'],
    single_hop => $single_hop,
    v3         => $v3
  }

  file {
    '/var/lib/tor/static/':
      ensure => directory,
      owner  => 'debian-tor',
      group  => 'debian-tor',
      mode   => '2700';

    '/var/lib/tor/static/private_key':
      ensure => present,
      source => "/srv/leap/files/nodes/${::hostname}/tor.key",
      owner  => 'debian-tor',
      group  => 'debian-tor',
      mode   => '0600',
      notify => Service['tor'];

    '/var/lib/tor/static/hostname':
      ensure  => present,
      content => "${::site_static::onion_domain}\n",
      owner   => 'debian-tor',
      group   => 'debian-tor',
      mode    => '0600',
      notify  => Service['tor'];
  }

  # it is necessary to zero out the config of the status module
  # because we are configuring our own version that is unavailable
  # over the hidden service (see: #7456 and #7776)
  apache::module { 'status': ensure => present, conf_content => ' ' }

  include site_shorewall::tor
}

