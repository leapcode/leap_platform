class site_couchdb {

  $x509 = hiera('x509')
  $key  = $x509['key']
  $cert = $x509['cert']

  # install couchdb package first, then configure it
  Class['site_couchdb::package'] -> Class['site_couchdb::configure']

  include site_couchdb::package
  include site_couchdb::configure
  include couchdb::deploy_config

  include apache::ssl
  apache::module {
    'rewrite':      ensure => present;
    'proxy':        ensure => present;
    'proxy_http':   ensure => present;
  }
  apache::vhost::file { 'couchdb_proxy': }
  # prevent 0-default.conf and 0-default_ssl.conf from apache module
  # from starting on port 80 / 443
  file { '/etc/apache2/ports.conf':
    content => '',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
  }

  file { '/etc/couchdb/server_cert.pem':
    mode    => '0644',
    owner   => 'couchdb',
    group   => 'couchdb',
    content => $cert,
    notify  => Service[apache],
  }

  file { '/etc/couchdb/server_key.pem':
    mode    => '0600',
    owner   => 'couchdb',
    group   => 'couchdb',
    content => $key,
    notify  => Service[apache],
  }

}
