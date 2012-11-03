class site_couchdb {

  $x509                       = hiera('x509')
  $key                        = $x509['key']
  $cert                       = $x509['cert']
  $adminpw                    = hiera('couchdb_adminpw')
  $couchdb_leap_web_user      = hiera('couchdb_leap_web_user')
  $couchdb_leap_web_username  = $couchdb_leap_web_user['user']
  $couchdb_leap_web_pw        = $couchdb_leap_web_user['pw']
  $couchdb_leap_ca_user       = hiera('couchdb_leap_ca_user')
  $couchdb_leap_ca_username   = $couchdb_leap_ca_user['user']
  $couchdb_leap_ca_pw         = $couchdb_leap_ca_user['pw']
  $couchdb_host               = "admin:$adminpw@127.0.0.1:5984"

  # install couchdb package first, then configure it
  Class['site_couchdb::package'] -> Class['site_couchdb::configure']

  include site_couchdb::package
  include site_couchdb::configure
  include couchdb::deploy_config

  site_couchdb::apache_ssl_proxy { 'apache_ssl_proxy':
    key   => $key,
    cert  => $cert
  }

  couchdb::add_user { $couchdb_leap_web_username:
    host  => $couchdb_host,
    roles => '["certs"]',
    pw    => $couchdb_leap_web_pw
  }

  couchdb::add_user { $couchdb_leap_ca_username:
    host  => $couchdb_host,
    roles => '["certs"]',
    pw    => $couchdb_leap_ca_pw
  }

  couchdb::create_db { 'leap_web':
    host    => $couchdb_host,
    readers => "{ \"names\": [\"leap_web\"], \"roles\": [] }"
  }

  couchdb::create_db { 'leap_ca':
    host    => $couchdb_host,
    readers => "{ \"names\": [], \"roles\": [\"certs\"] }"
  }
}
