class site_couchdb::add_users {

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
    roles   => '["identities"]',
    pw      => $site_couchdb::couchdb_nickserver_pw,
    salt    => $site_couchdb::couchdb_nickserver_salt,
    require => Couchdb::Query::Setup['localhost']
  }

  ## soledad couchdb user
  ## read: tokens, user-<uuid>, shared
  ## write: user-<uuid>, shared
  couchdb::add_user { $site_couchdb::couchdb_soledad_user:
    roles   => '["auth"]',
    pw      => $site_couchdb::couchdb_soledad_pw,
    salt    => $site_couchdb::couchdb_soledad_salt,
    require => Couchdb::Query::Setup['localhost']
  }

  ## webapp couchdb user
  ## read/write: users, tokens, sessions, tickets, identities
  couchdb::add_user { $site_couchdb::couchdb_webapp_user:
    roles   => '["auth","identities"]',
    pw      => $site_couchdb::couchdb_webapp_pw,
    salt    => $site_couchdb::couchdb_webapp_salt,
    require => Couchdb::Query::Setup['localhost']
  }

}
