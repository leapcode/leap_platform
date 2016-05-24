define couchdb::query::setup ($user, $pw, $host='127.0.0.1') {

  file { "/etc/couchdb/couchdb-${user}.netrc":
    content => "machine ${host} login ${user} password ${pw}",
    mode    => '0600',
    owner   => $::couchdb::base::couchdb_user,
    group   => $::couchdb::base::couchdb_user,
    require => Package['couchdb'];
  }
}
