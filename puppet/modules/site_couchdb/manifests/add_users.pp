class site_couchdb::add_users {

  # Populate couchdb

  couchdb::add_user { $site_couchdb::couchdb_soledad_user:
    roles   => '["auth"]',
    pw      => $site_couchdb::couchdb_soledad_pw,
    salt    => $site_couchdb::couchdb_soledad_salt,
    require => Couchdb::Query::Setup['localhost']
  }

  couchdb::add_user { $site_couchdb::couchdb_webapp_user:
    roles   => '["auth"]',
    pw      => $site_couchdb::couchdb_webapp_pw,
    salt    => $site_couchdb::couchdb_webapp_salt,
    require => Couchdb::Query::Setup['localhost']
  }

}
