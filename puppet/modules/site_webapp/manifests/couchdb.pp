class site_webapp::couchdb {

  $webapp                  = hiera('webapp')
  # haproxy listener on port localhost:4096, see site_webapp::haproxy
  $couchdb_host            = 'localhost'
  $couchdb_port            = '4096'
  $couchdb_webapp_user     = $webapp['couchdb_webapp_user']['username']
  $couchdb_webapp_password = $webapp['couchdb_webapp_user']['password']
  $couchdb_admin_user      = $webapp['couchdb_admin_user']['username']
  $couchdb_admin_password  = $webapp['couchdb_admin_user']['password']

  include x509::variables

  file {
    '/srv/leap/webapp/config/couchdb.yml':
      content => template('site_webapp/couchdb.yml.erb'),
      owner   => leap-webapp,
      group   => leap-webapp,
      mode    => '0600',
      require => Vcsrepo['/srv/leap/webapp'];

    '/srv/leap/webapp/config/couchdb.admin.yml':
      content => template('site_webapp/couchdb.admin.yml.erb'),
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
}
