# setup soledad-server
class soledad::server {
  tag 'leap_service'

  include site_config::default
  include soledad::common

  $soledad              = hiera('soledad')
  $couchdb_user         = $soledad['couchdb_soledad_user']['username']
  $couchdb_password     = $soledad['couchdb_soledad_user']['password']
  $couchdb_leap_mx_user = $soledad['couchdb_leap_mx_user']['username']

  $couchdb_host = 'localhost'
  $couchdb_port = '5984'

  $soledad_port = $soledad['port']

  $sources      = hiera('sources')

  include x509::variables
  include site_config::x509::cert
  include site_config::x509::key
  include site_config::x509::ca

  #
  # SOLEDAD CONFIG
  #

  file {
    '/etc/soledad':
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0755';
    '/etc/soledad/soledad-server.conf':
      content => template('soledad/soledad-server.conf.erb'),
      owner   => 'soledad',
      group   => 'soledad',
      mode    => '0640',
      notify  => Service['soledad-server'],
      require => [ User['soledad'], Group['soledad'] ];
    '/srv/leap/soledad':
      ensure  => directory,
      owner   => 'soledad',
      group   => 'soledad',
      require => [ User['soledad'], Group['soledad'] ];
    '/var/lib/soledad':
      ensure  => directory,
      owner   => 'soledad',
      group   => 'soledad',
      require => [ User['soledad'], Group['soledad'] ];
  }

  package { $sources['soledad']['package']:
    ensure  => $sources['soledad']['revision'],
    require => Class['site_apt::leap_repo'];
  }

  file { '/etc/default/soledad':
    content => template('soledad/default-soledad.erb'),
    owner   => 'soledad',
    group   => 'soledad',
    mode    => '0600',
    notify  => Service['soledad-server'],
    require => [ User['soledad'], Group['soledad'] ];
  }

  service { 'soledad-server':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => [ User['soledad'], Group['soledad'] ],
    subscribe  => [
      Package['soledad-server'],
      Class['Site_config::X509::Key'],
      Class['Site_config::X509::Cert'],
      Class['Site_config::X509::Ca'] ];
  }

  include site_shorewall::soledad
  include site_check_mk::agent::soledad

  # set up users, group and directories for soledad-server
  # although the soledad users are already created by the
  # soledad-server package
  group { 'soledad':
    ensure => present,
    system => true,
  }
  user {
    'soledad':
      ensure    => present,
      system    => true,
      gid       => 'soledad',
      home      => '/srv/leap/soledad',
      require   => Group['soledad'];
    'soledad-admin':
      ensure  => present,
      system  => true,
      gid     => 'soledad',
      home    => '/srv/leap/soledad',
      require => Group['soledad'];
  }
}
