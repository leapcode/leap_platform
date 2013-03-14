class site_webapp::couchdb {

  $x509             = hiera('x509')
  $key              = $x509['key']
  $cert             = $x509['cert']
  $ca               = $x509['ca_cert']
  $webapp           = hiera('webapp')
  $couchdb_host     = $webapp['couchdb_hosts']
  $couchdb_user     = $webapp['couchdb_user']['username']
  $couchdb_password = $webapp['couchdb_user']['password']

  file {
    '/srv/leap-webapp/config/couchdb.yml':
      content => template('site_webapp/couchdb.yml.erb'),
      owner   => leap-webapp,
      group   => leap-webapp,
      mode    => '0600';
  }

  class { 'site_webapp::couchdb_stunnel':
    key  => $key,
    cert => $cert,
    ca   => $ca
  }
}
