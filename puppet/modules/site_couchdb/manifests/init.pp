class site_couchdb {
  tag 'leap_service'
  include couchdb

  $x509                   = hiera('x509')
  $key                    = $x509['key']
  $cert                   = $x509['cert']
  $couchdb_config         = hiera('couch')
  $couchdb_users          = $couchdb_config['users']
  $couchdb_admin          = $couchdb_users['admin']
  $couchdb_admin_user     = $couchdb_admin['username']
  $couchdb_admin_pw       = $couchdb_admin['password']
  $couchdb_webapp         = $couchdb_users['webapp']
  $couchdb_webapp_user    = $couchdb_webapp['username']
  $couchdb_webapp_pw      = $couchdb_webapp['password']
  $couchdb_ca_daemon      = $couchdb_users['ca_daemon']
  $couchdb_ca_daemon_user = $couchdb_ca_daemon['username']
  $couchdb_ca_daemon_pw   = $couchdb_ca_daemon['password']

  Package ['couchdb']
    -> File['/etc/init.d/couchdb']
    -> File['/etc/couchdb/local.ini']
    -> File['/etc/couchdb/local.d/admin.ini']
    -> File['/etc/couchdb/couchdb.netrc']
    -> Couchdb::Create_db['users']
    -> Couchdb::Create_db['client_certificates']
    -> Couchdb::Add_user[$couchdb_webapp_user]
    -> Couchdb::Add_user[$couchdb_ca_daemon_user]
    -> Site_couchdb::Apache_ssl_proxy['apache_ssl_proxy']

  include site_couchdb::configure
  include couchdb::deploy_config

  site_couchdb::apache_ssl_proxy { 'apache_ssl_proxy':
    key   => $key,
    cert  => $cert
  }

  couchdb::query::setup { 'localhost':
    user  => $couchdb_admin_user,
    pw    => $couchdb_admin_pw
  }

  # Populate couchdb
  couchdb::add_user { $couchdb_webapp_user:
    roles => '["certs"]',
    pw    => $couchdb_webapp_pw
  }

  couchdb::add_user { $couchdb_ca_daemon_user:
    roles => '["certs"]',
    pw    => $couchdb_ca_daemon_pw
  }

  couchdb::create_db { 'users':
    readers => "{ \"names\": [\"$couchdb_webapp_user\"], \"roles\": [] }"
  }

  couchdb::create_db { 'client_certificates':
    readers => "{ \"names\": [], \"roles\": [\"certs\"] }"
  }
}
