# this class sets up a single, plain couchdb node
class site_couchdb::master {
  class { 'couchdb':
    admin_pw            => $site_couchdb::couchdb_admin_pw,
    admin_salt          => $site_couchdb::couchdb_admin_salt,
    chttpd_bind_address => '127.0.0.1',
    pwhash_alg          => $site_couchdb::couchdb_pwhash_alg
  }

  # couchdb is not available in jessie, and the
  # leap deb repo only hosts a wheeyz version.
  # we install it therefore from unstable
  include site_apt::sid_repo

  include site_check_mk::agent::couchdb::master
}
