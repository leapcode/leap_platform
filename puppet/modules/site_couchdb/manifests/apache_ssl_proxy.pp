define site_couchdb::apache_ssl_proxy ($key, $cert) {

  $apache_no_default_site = true
  include apache
  apache::module {
    'proxy':        ensure => present;
    'proxy_http':   ensure => present;
    'rewrite':      ensure => present;
    'ssl':          ensure => present;
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
