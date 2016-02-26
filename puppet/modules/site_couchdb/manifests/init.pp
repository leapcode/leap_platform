# entry class for configuring couchdb/bigcouch node
# couchdb node
class site_couchdb {
  tag 'leap_service'

  $couchdb_config           = hiera('couch')
  $couchdb_users            = $couchdb_config['users']

  $couchdb_admin            = $couchdb_users['admin']
  $couchdb_admin_user       = $couchdb_admin['username']
  $couchdb_admin_pw         = $couchdb_admin['password']
  $couchdb_admin_salt       = $couchdb_admin['salt']

  $couchdb_leap_mx          = $couchdb_users['leap_mx']
  $couchdb_leap_mx_user     = $couchdb_leap_mx['username']
  $couchdb_leap_mx_pw       = $couchdb_leap_mx['password']
  $couchdb_leap_mx_salt     = $couchdb_leap_mx['salt']

  $couchdb_nickserver       = $couchdb_users['nickserver']
  $couchdb_nickserver_user  = $couchdb_nickserver['username']
  $couchdb_nickserver_pw    = $couchdb_nickserver['password']
  $couchdb_nickserver_salt  = $couchdb_nickserver['salt']

  $couchdb_soledad          = $couchdb_users['soledad']
  $couchdb_soledad_user     = $couchdb_soledad['username']
  $couchdb_soledad_pw       = $couchdb_soledad['password']
  $couchdb_soledad_salt     = $couchdb_soledad['salt']

  $couchdb_webapp           = $couchdb_users['webapp']
  $couchdb_webapp_user      = $couchdb_webapp['username']
  $couchdb_webapp_pw        = $couchdb_webapp['password']
  $couchdb_webapp_salt      = $couchdb_webapp['salt']

  $couchdb_replication      = $couchdb_users['replication']
  $couchdb_replication_user = $couchdb_replication['username']
  $couchdb_replication_pw   = $couchdb_replication['password']
  $couchdb_replication_salt = $couchdb_replication['salt']

  $couchdb_backup           = $couchdb_config['backup']
  $couchdb_mode             = $couchdb_config['mode']
  $couchdb_pwhash_alg       = $couchdb_config['pwhash_alg']

  # ensure bigcouch has been purged from the system:
  # TODO: remove this check in 0.9 release
  if file('/opt/bigcouch/bin/bigcouch', '/dev/null') != '' {
    fail 'ERROR: BigCouch appears to be installed. Make sure you have migrated to CouchDB before proceeding. See https://leap.se/upgrade-0-8'
  }

  include site_couchdb::plain

  Class['site_config::default']
    -> Service['shorewall']
    -> Exec['refresh_stunnel']
    -> Class['couchdb']
    -> Class['site_couchdb::setup']

  include ::site_config::default
  include site_stunnel

  include site_couchdb::setup
  include site_couchdb::create_dbs
  include site_couchdb::add_users
  include site_couchdb::designs
  include site_couchdb::logrotate

  if $couchdb_backup   { include site_couchdb::backup }

  include site_check_mk::agent::couchdb

  # remove tapicero leftovers on couchdb nodes
  include site_config::remove::tapicero

  # Destroy every per-user storage database
  # where the corresponding user record does not exist.
  cron { 'cleanup_stale_userdbs':
    command => '(/bin/date; /srv/leap/couchdb/scripts/cleanup-user-dbs) >> /var/log/leap/couchdb-cleanup.log',
    user    => 'root',
    hour    => 4,
    minute  => 7;
  }

}
