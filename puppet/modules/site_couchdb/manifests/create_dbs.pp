# creates neccesary databases
class site_couchdb::create_dbs {

  Class['site_couchdb::setup']
    -> Class['site_couchdb::create_dbs']

  ### customer database
  ### r/w: webapp,
  couchdb::create_db { 'customers':
    members => "{ \"names\": [\"${site_couchdb::couchdb_webapp_user}\"], \"roles\": [\"replication\"] }",
    require => Couchdb::Query::Setup['localhost']
  }

  ## identities database
  ## r: nickserver, leap_mx - needs to be restrict with design document
  ## r/w: webapp
  couchdb::create_db { 'identities':
    members => "{ \"names\": [], \"roles\": [\"replication\", \"identities\"] }",
    require => Couchdb::Query::Setup['localhost']
  }

  ## keycache database
  ## r/w: nickserver
  couchdb::create_db { 'keycache':
    members => "{ \"names\": [], \"roles\": [\"replication\", \"keycache\"] }",
    require => Couchdb::Query::Setup['localhost']
  }

  ## sessions database
  ## r/w: webapp
  $sessions_db = rotated_db_name('sessions', 'monthly')
  couchdb::create_db { $sessions_db:
    members => "{ \"names\": [\"${site_couchdb::couchdb_webapp_user}\"], \"roles\": [\"replication\"] }",
    require => Couchdb::Query::Setup['localhost']
  }

  $sessions_next_db = rotated_db_name('sessions', 'monthly', 'next')
  couchdb::create_db { $sessions_next_db:
    members => "{ \"names\": [\"${site_couchdb::couchdb_webapp_user}\"], \"roles\": [\"replication\"] }",
    require => Couchdb::Query::Setup['localhost']
  }

  ## shared database
  ## r/w: soledad
  couchdb::create_db { 'shared':
    members => "{ \"names\": [\"${site_couchdb::couchdb_soledad_user}\"], \"roles\": [\"replication\"] }",
    require => Couchdb::Query::Setup['localhost']
  }

  ## tickets database
  ## r/w: webapp
  couchdb::create_db { 'tickets':
    members => "{ \"names\": [\"${site_couchdb::couchdb_webapp_user}\"], \"roles\": [\"replication\"] }",
    require => Couchdb::Query::Setup['localhost']
  }

  ## tokens database
  ## r: soledad - needs to be restricted with a design document
  ## r/w: webapp
  $tokens_db = rotated_db_name('tokens', 'monthly')
  couchdb::create_db { $tokens_db:
    members => "{ \"names\": [], \"roles\": [\"replication\", \"tokens\"] }",
    require => Couchdb::Query::Setup['localhost']
  }

  $tokens_next_db = rotated_db_name('tokens', 'monthly', 'next')
  couchdb::create_db { $tokens_next_db:
    members => "{ \"names\": [], \"roles\": [\"replication\", \"tokens\"] }",
    require => Couchdb::Query::Setup['localhost']
  }

  ## users database
  ## r/w: webapp
  couchdb::create_db { 'users':
    members => "{ \"names\": [], \"roles\": [\"replication\", \"users\"] }",
    require => Couchdb::Query::Setup['localhost']
  }

  ## tmp_users database
  ## r/w: webapp
  couchdb::create_db { 'tmp_users':
    members => "{ \"names\": [], \"roles\": [\"replication\", \"users\"] }",
    require => Couchdb::Query::Setup['localhost']
  }

  ## messages db
  ## store messages to the clients such as payment reminders
  ## r/w: webapp
  couchdb::create_db { 'messages':
    members => "{ \"names\": [\"${site_couchdb::couchdb_webapp_user}\"], \"roles\": [\"replication\"] }",
    require => Couchdb::Query::Setup['localhost']
  }
}
