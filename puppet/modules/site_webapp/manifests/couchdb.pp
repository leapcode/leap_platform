class site_webapp::couchdb {

  $webapp                  = hiera('webapp')
  # haproxy listener on port localhost:4096, see site_webapp::haproxy
  $couchdb_host            = 'localhost'
  $couchdb_port            = '4096'
  $couchdb_webapp_user     = $webapp['couchdb_webapp_user']['username']
  $couchdb_webapp_password = $webapp['couchdb_webapp_user']['password']

  $stunnel                 = hiera('stunnel')
  $couch_client            = $stunnel['couch_client']
  $couch_client_connect    = $couch_client['connect']

  include x509::variables

  file {
    '/srv/leap/webapp/config/couchdb.yml.webapp':
      content => template('site_webapp/couchdb.yml.erb'),
      owner   => leap-webapp,
      group   => leap-webapp,
      mode    => '0600',
      require => Vcsrepo['/srv/leap/webapp'];

    '/srv/leap/webapp/log':
      ensure  => directory,
      owner   => leap-webapp,
      group   => leap-webapp,
      mode    => '0755',
      require => Vcsrepo['/srv/leap/webapp'];

    '/srv/leap/webapp/log/production.log':
      ensure  => present,
      owner   => leap-webapp,
      group   => leap-webapp,
      mode    => '0666',
      require => Vcsrepo['/srv/leap/webapp'];
  }

  include site_stunnel

  $couchdb_stunnel_client_defaults = {
    'connect_port' => $couch_client_connect,
    'client'       => true,
    'cafile'       => "${x509::variables::local_CAs}/${site_config::params::ca_name}.crt",
    'key'          => "${x509::variables::keys}/${site_config::params::cert_name}.key",
    'cert'         => "${x509::variables::certs}/${site_config::params::cert_name}.crt",
  }

  create_resources(site_stunnel::clients, $couch_client, $couchdb_stunnel_client_defaults)
}
