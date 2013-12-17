class site_couchdb::create_dbs {

  # Couchdb databases

  ### customer database
  ### r/w: webapp,
  couchdb::create_db { 'customers':
    members => "{ \"names\": [\"$site_couchdb::couchdb_webapp_user\"], \"roles\": [] }",
    require => Couchdb::Query::Setup['localhost']
  }

  ## identities database
  ## r: nickserver, leap_mx - needs to be restrict with design document
  ## r/w: webapp
  couchdb::create_db { 'identities':
    members => "{ \"names\": [], \"roles\": [\"identities\"] }",
    require => Couchdb::Query::Setup['localhost']
  }

  ## keycache database
  ## r/w: nickserver
  couchdb::create_db { 'keycache':
    members => "{ \"names\": [], \"roles\": [\"keycache\"] }",
    require => Couchdb::Query::Setup['localhost']
  }

  ## sessions database
  ## r/w: webapp
  couchdb::create_db { 'sessions':
    members => "{ \"names\": [\"$site_couchdb::couchdb_webapp_user\"], \"roles\": [] }",
    require => Couchdb::Query::Setup['localhost']
  }

  ## shared database
  ## r/w: soledad
  couchdb::create_db { 'shared':
    members => "{ \"names\": [\"$site_couchdb::couchdb_soledad_user\"], \"roles\": [] }",
    require => Couchdb::Query::Setup['localhost']
  }

  ## tickets database
  ## r/w: webapp
  couchdb::create_db { 'tickets':
    members => "{ \"names\": [\"$site_couchdb::couchdb_webapp_user\"], \"roles\": [] }",
    require => Couchdb::Query::Setup['localhost']
  }

  ## tokens database
  ## r: soledad - needs to be restricted with a design document
  ## r/w: webapp
  couchdb::create_db { 'tokens':
    members => "{ \"names\": [], \"roles\": [\"tokens\"] }",
    require => Couchdb::Query::Setup['localhost']
  }

  ## users database
  ## r/w: webapp
  couchdb::create_db { 'users':
    members => "{ \"names\": [], \"roles\": [\"users\"] }",
    require => Couchdb::Query::Setup['localhost']
  }
}
