class site_couchdb::create_dbs {

  couchdb::create_db { 'users':
    members => "{ \"names\": [\"$site_couchdb::couchdb_webapp_user\"], \"roles\": [] }",
    require => Couchdb::Query::Setup['localhost']
  }

  couchdb::create_db { 'tokens':
    members => "{ \"names\": [], \"roles\": [\"auth\"] }",
    require => Couchdb::Query::Setup['localhost']
  }

  couchdb::create_db { 'sessions':
    members => "{ \"names\": [\"$site_couchdb::couchdb_webapp_user\"], \"roles\": [] }",
    require => Couchdb::Query::Setup['localhost']
  }

  couchdb::create_db { 'tickets':
    members => "{ \"names\": [\"$site_couchdb::couchdb_webapp_user\"], \"roles\": [] }",
    require => Couchdb::Query::Setup['localhost']
  }

  # leap_mx will want access to this. Granting access to the soledad user
  # via the auth group for now.
  # leap_mx could use that for a start.
  couchdb::create_db { 'identities':
    members => "{ \"names\": [], \"roles\": [\"auth\"] }",
    require => Couchdb::Query::Setup['localhost']
  }

}
