class site_couchdb::mirror {

  class { 'couchdb':
    admin_pw            => $site_couchdb::couchdb_admin_pw,
    admin_salt          => $site_couchdb::couchdb_admin_salt,
    chttpd_bind_address => '127.0.0.1'
  }

  # Couchdb databases

  $masters = $site_couchdb::couchdb_config['replication']['masters']
  $master_node_names = keys($site_couchdb::couchdb_config['replication']['masters'])
  $master_node = $masters[$master_node_names[0]]
  $from_host = $master_node['domain_internal']
  $from_port = $master_node['couch_port']
  $from = "${from_host}:${from_port}"

  notice("mirror from: ${from}")

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
