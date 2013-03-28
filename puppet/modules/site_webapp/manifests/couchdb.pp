class site_webapp::couchdb {

  $x509                    = hiera('x509')
  $key                     = $x509['key']
  $cert                    = $x509['cert']
  $ca                      = $x509['ca_cert']
  $webapp                  = hiera('webapp')
  # haproxy listener on port localhost:4096, see site_webapp::haproxy
  $couchdb_host            = 'localhost'
  $couchdb_port            = '4096'
  $couchdb_admin_user      = $webapp['couchdb_admin_user']['username']
  $couchdb_admin_password  = $webapp['couchdb_admin_user']['password']
  $couchdb_webapp_user     = $webapp['couchdb_webapp_user']['username']
  $couchdb_webapp_password = $webapp['couchdb_webapp_user']['password']

  file {
    '/srv/leap-webapp/config/couchdb.yml.admin':
      content => template('site_webapp/couchdb.yml.admin.erb'),
      owner   => leap-webapp,
      group   => leap-webapp,
      mode    => '0600';

    '/srv/leap-webapp/config/couchdb.yml.webapp':
      content => template('site_webapp/couchdb.yml.erb'),
      owner   => leap-webapp,
      group   => leap-webapp,
      mode    => '0600';

    '/usr/local/sbin/migrate_design_documents':
      source => 'puppet:///modules/site_webapp/migrate_design_documents',
      owner  => root,
      group  => root,
      mode   => '0744';
  }

  class { 'site_webapp::couchdb_stunnel':
    key  => $key,
    cert => $cert,
    ca   => $ca
  }

  exec { 'migrate_design_documents':
    cwd      => '/srv/leap-webapp',
    command  => '/usr/local/sbin/migrate_design_documents',
    require  => Exec['bundler_update'],
    notify   => Service['apache'];
  }
}
