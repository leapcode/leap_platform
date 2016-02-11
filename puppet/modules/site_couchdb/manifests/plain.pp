# this class sets up a single, plain couchdb node
class site_couchdb::plain {
  class { 'couchdb':
    admin_pw            => $site_couchdb::couchdb_admin_pw,
    admin_salt          => $site_couchdb::couchdb_admin_salt,
    chttpd_bind_address => '127.0.0.1',
    pwhash_alg          => 'pbkdf2'
  }

  include site_check_mk::agent::couchdb::plain

  # remove bigcouch leftovers from previous installations
  include ::site_config::remove::bigcouch

}
