class site_couchdb::create_dbs {

  # identities database
  # r/w: webapp
  # r: nickserver, leap_mx - need to restrict with design document
  couchdb::create_db { 'identities':
    members => "{ \"names\": [], \"roles\": [\"identities\"] }",
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

  couchdb::create_db { 'tokens':
    members => "{ \"names\": [], \"roles\": [\"auth\"] }",
    require => Couchdb::Query::Setup['localhost']
  }

  couchdb::create_db { 'users':
    members => "{ \"names\": [\"$site_couchdb::couchdb_webapp_user\"], \"roles\": [] }",
    require => Couchdb::Query::Setup['localhost']
  }
}
