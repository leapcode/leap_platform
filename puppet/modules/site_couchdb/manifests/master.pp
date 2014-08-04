class site_couchdb::master {

  class { 'couchdb':
    admin_pw            => $site_couchdb::couchdb_admin_pw,
    admin_salt          => $site_couchdb::couchdb_admin_salt,
    chttpd_bind_address => '127.0.0.1'
  }

}