class site_webapp::couchdb {

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

}
