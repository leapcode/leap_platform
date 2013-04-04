class site_webapp::couchdb {

  $webapp                  = hiera('webapp')
  # haproxy listener on port localhost:4096, see site_webapp::haproxy
  $couchdb_host            = 'localhost'
  $couchdb_port            = '4096'
  $couchdb_admin_user      = $webapp['couchdb_admin_user']['username']
  $couchdb_admin_password  = $webapp['couchdb_admin_user']['password']
  $couchdb_webapp_user     = $webapp['couchdb_webapp_user']['username']
  $couchdb_webapp_password = $webapp['couchdb_webapp_user']['password']

  $stunnel                 = hiera('stunnel')
  $couch_client            = $stunnel['couch_client']
  $couch_client_connect    = $couch_client['connect']

  include x509::variable
  $x509                    = hiera('x509')
  $key                     = $x509['key']
  $cert                    = $x509['cert']
  $ca                      = $x509['ca_cert']
  $cert_name               = 'leap_couchdb'
  $ca_name                 = 'leap_ca'
  $ca_path                 = "${x509::variables::local_CAs}/${ca_name}.crt"
  $cert_path               = "${x509::variables::certs}/${cert_name}.crt"
  $key_path                = "${x509::variables::keys}/${cert_name}.key"

  file {
    '/srv/leap-webapp/config/couchdb.yml.admin':
      content => template('site_webapp/couchdb.yml.admin.erb'),
      owner   => root,
      group   => root,
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

  class { 'site_stunnel::setup':
    cert_name => $cert_name,
    key       => $key,
    cert      => $cert,
    ca_name   => $ca_name,
    ca        => $ca
  }

  exec { 'migrate_design_documents':
    cwd      => '/srv/leap-webapp',
    command  => '/usr/local/sbin/migrate_design_documents',
    require  => Exec['bundler_update'],
    notify   => Service['apache'];
  }

  $couchdb_stunnel_client_defaults = {
    'connect_port' => $couch_client_connect,
    'client'     => true,
    'cafile'     => $ca_path,
    'key'        => $key_path,
    'cert'       => $cert_path,
  }

  create_resources(site_stunnel::clients, $couch_client, $couchdb_stunnel_client_defaults)
}
