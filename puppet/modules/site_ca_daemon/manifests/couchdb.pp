class site_ca_daemon::couchdb {

  $ca               = hiera('ca_daemon')
  $couchdb_host     = $ca['couchdb_hosts']
  $couchdb_user     = $ca['couchdb_user']['username']
  $couchdb_password = $ca['couchdb_user']['password']

  file {
    '/srv/leap_ca_daemon/config/couchdb.yml':
      content => template('site_ca_daemon/couchdb.yml.erb'),
      owner   => leap_ca_daemon,
      group   => leap_ca_daemon,
      mode    => '0600';
  }

}
