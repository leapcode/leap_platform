class site_couchdb::mirror {

  # Couchdb databases

  $from = $site_couchdb::couchdb_config['replication']['masters'][0]

  ### customer database
  couchdb::mirror_db { 'customers':
    from => $from,
    require => Couchdb::Query::Setup['localhost']
  }

  ## identities database
  couchdb::mirror_db { 'identities':
    from => $from,
    require => Couchdb::Query::Setup['localhost']
  }

  ## keycache database
  couchdb::mirror_db { 'keycache':
    from => $from,
    require => Couchdb::Query::Setup['localhost']
  }

  ## sessions database
  couchdb::mirror_db { 'sessions':
    from => $from,
    require => Couchdb::Query::Setup['localhost']
  }

  ## shared database
  couchdb::mirror_db { 'shared':
    from => $from,
    require => Couchdb::Query::Setup['localhost']
  }

  ## tickets database
  couchdb::mirror_db { 'tickets':
    from => $from,
    require => Couchdb::Query::Setup['localhost']
  }

  ## tokens database
  couchdb::mirror_db { 'tokens':
    from => $from,
    require => Couchdb::Query::Setup['localhost']
  }

  ## users database
  couchdb::mirror_db { 'users':
    from => $from,
    require => Couchdb::Query::Setup['localhost']
  }

  ## messages db
  couchdb::mirror_db { 'messages':
    from => $from,
    require => Couchdb::Query::Setup['localhost']
  }

}
