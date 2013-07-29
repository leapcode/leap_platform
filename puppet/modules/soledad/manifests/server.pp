class soledad::server {
  tag 'leap_service'
  include soledad

  $couchdb          = hiera('soledad')
  $couchdb_host     = 'localhost'
  $couchdb_port     = '5984'
  $couchdb_user     = $couchdb['couchdb_admin_user']['username']
  $couchdb_password = $couchdb['couchdb_admin_user']['password']

  $x509      = hiera('x509')
  $x509_key  = $x509['key']
  $x509_cert = $x509['cert']
  $x509_ca   = $x509['ca_cert']

  x509::key { 'soledad':
    content => $x509_key,
    notify  => Service['soledad-server'];
  }

  x509::cert { 'soledad':
    content => $x509_cert,
    notify  => Service['soledad-server'];
  }

  x509::ca { 'soledad':
    content => $x509_ca,
    notify  => Service['soledad-server'];
  }

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
    ensure => installed
  }

  file { '/etc/default/soledad':
    content => "CERT_PATH=/etc/x509/certs/soledad.crt\nPRIVKEY_PATH=/etc/x509/keys/soledad.key\n",
    require => Package['soledad-server']
  }

  service { 'soledad-server':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => [ Class['soledad'], Package['soledad-server'] ];
  }

  include site_shorewall::soledad
}
