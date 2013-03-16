class site_webapp::couchdb {

  $webapp           = hiera('webapp')
  $couchdb_hosts    = $webapp['couchdb_hosts']
  # for now, pick the first couchdb host before we have a working
  # load balancing setup (see https://leap.se/code/issues/1994)
  $couchdb_host     = $couchdb_hosts[0]
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
