class soledad::server {
  tag 'leap_service'
  include soledad
  include site_apt::preferences::twisted

  $couchdb           = hiera('couch')
  $couchdb_users     = $couchdb['users']
  $couchdb_user      = $couchdb_users['soledad']['username']
  $couchdb_password  = $couchdb_users['soledad']['password']

  $couchdb_host = 'localhost'
  $couchdb_port = '5984'

  $soledad      = hiera('soledad')
  $soledad_port = $soledad['port']

  include site_config::x509::cert
  include site_config::x509::key
  include site_config::x509::ca

  #
  # SOLEDAD CONFIG
  #

  file { '/etc/leap/soledad-server.conf':
    content => template('soledad/soledad-server.conf.erb'),
    owner   => 'soledad',
    group   => 'soledad',
    mode    => '0600',
    notify  => Service['soledad-server'],
    require => Class['soledad'];
  }

  package { 'soledad-server':
    ensure  => latest,
    require => [
      Class['site_apt::preferences::twisted'],
      Class['site_apt::leap_repo'] ];
  }

  file { '/etc/default/soledad':
    content => template('soledad/default-soledad.erb'),
    owner   => 'soledad',
    group   => 'soledad',
    mode    => '0600',
    notify  => Service['soledad-server'],
    require => Class['soledad'];
  }

  service { 'soledad-server':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => [
      Class['soledad'],
      Package['soledad-server'],
      Class['Site_config::X509::Key'],
      Class['Site_config::X509::Cert'],
      Class['Site_config::X509::Ca'] ];
  }

  include site_shorewall::soledad
}
