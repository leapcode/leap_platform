# add couchdb users for all services
class site_couchdb::add_users {

  Class['site_couchdb::create_dbs']
    -> Class['site_couchdb::add_users']

  # Couchdb users

  ## leap_mx couchdb user
  ## read: identities
  ## write access to user-<uuid>
  couchdb::add_user { $site_couchdb::couchdb_leap_mx_user:
    roles   => '["identities"]',
    pw      => $site_couchdb::couchdb_leap_mx_pw,
    salt    => $site_couchdb::couchdb_leap_mx_salt,
    require => Couchdb::Query::Setup['localhost']
  }

  ## nickserver couchdb user
  ## r: identities
  ## r/w: keycache
  couchdb::add_user { $site_couchdb::couchdb_nickserver_user:
    roles   => '["identities","keycache"]',
    pw      => $site_couchdb::couchdb_nickserver_pw,
    salt    => $site_couchdb::couchdb_nickserver_salt,
    require => Couchdb::Query::Setup['localhost']
  }

  ## soledad couchdb user
  ## r/w: user-<uuid>, shared
  ## read: tokens
  couchdb::add_user { $site_couchdb::couchdb_soledad_user:
    roles   => '["tokens"]',
    pw      => $site_couchdb::couchdb_soledad_pw,
    salt    => $site_couchdb::couchdb_soledad_salt,
    require => Couchdb::Query::Setup['localhost'],
    notify  => Service['soledad-server'];
  }

  ## webapp couchdb user
  ## read/write: users, tokens, sessions, tickets, identities, customer
  couchdb::add_user { $site_couchdb::couchdb_webapp_user:
    roles   => '["tokens","identities","users"]',
    pw      => $site_couchdb::couchdb_webapp_pw,
    salt    => $site_couchdb::couchdb_webapp_salt,
    require => Couchdb::Query::Setup['localhost']
  }

  ## replication couchdb user
  ## read/write: all databases for replication
  couchdb::add_user { $site_couchdb::couchdb_replication_user:
    roles   => '["replication"]',
    pw      => $site_couchdb::couchdb_replication_pw,
    salt    => $site_couchdb::couchdb_replication_salt,
    require => Couchdb::Query::Setup['localhost']
  }

}
