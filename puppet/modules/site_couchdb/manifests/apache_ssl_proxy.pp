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

  x509::key {
    'leap_couchdb':
      content => $x509['key'],
      notify  => Service[apache];
  }

  x509::cert {
    'leap_couchdb':
      content => $x509['cert'],
      notify  => Service[apache];
  }

}
