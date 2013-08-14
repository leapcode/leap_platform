class site_couchdb {
  tag 'leap_service'

  $x509                   = hiera('x509')
  $key                    = $x509['key']
  $cert                   = $x509['cert']
  $ca                     = $x509['ca_cert']

  $couchdb_config         = hiera('couch')
  $couchdb_users          = $couchdb_config['users']
  $couchdb_admin          = $couchdb_users['admin']
  $couchdb_admin_user     = $couchdb_admin['username']
  $couchdb_admin_pw       = $couchdb_admin['password']
  $couchdb_admin_salt     = $couchdb_admin['salt']
  $couchdb_webapp         = $couchdb_users['webapp']
  $couchdb_webapp_user    = $couchdb_webapp['username']
  $couchdb_webapp_pw      = $couchdb_webapp['password']
  $couchdb_webapp_salt    = $couchdb_webapp['salt']
  $couchdb_soledad        = $couchdb_users['soledad']
  $couchdb_soledad_user   = $couchdb_soledad['username']
  $couchdb_soledad_pw     = $couchdb_soledad['password']
  $couchdb_soledad_salt   = $couchdb_soledad['salt']

  $bigcouch_config        = $couchdb_config['bigcouch']
  $bigcouch_cookie        = $bigcouch_config['cookie']

  $ednp_port              = $bigcouch_config['ednp_port']

  class { 'couchdb':
    bigcouch        => true,
    admin_pw        => $couchdb_admin_pw,
    admin_salt      => $couchdb_admin_salt,
    bigcouch_cookie => $bigcouch_cookie,
    ednp_port       => $ednp_port
  }

  class { 'couchdb::bigcouch::package::cloudant': }

  Class ['couchdb::bigcouch::package::cloudant']
    -> Service ['couchdb']
    -> Class ['site_couchdb::bigcouch::add_nodes']
    -> Couchdb::Create_db['users']
    -> Couchdb::Create_db['tokens']
    -> Couchdb::Add_user[$couchdb_webapp_user]
    -> Couchdb::Add_user[$couchdb_soledad_user]

  class { 'site_couchdb::stunnel':
    key  => $key,
    cert => $cert,
    ca   => $ca
  }

  class { 'site_couchdb::bigcouch::add_nodes': }

  couchdb::query::setup { 'localhost':
    user  => $couchdb_admin_user,
    pw    => $couchdb_admin_pw,
  }

  # Populate couchdb
  couchdb::add_user { $couchdb_webapp_user:
    roles   => '["auth"]',
    pw      => $couchdb_webapp_pw,
    salt    => $couchdb_webapp_salt,
    require => Couchdb::Query::Setup['localhost']
  }

  couchdb::add_user { $couchdb_soledad_user:
    roles => '["auth"]',
    pw    => $couchdb_soledad_pw,
    salt  => $couchdb_soledad_salt,
    require => Couchdb::Query::Setup['localhost']
  }

  couchdb::create_db { 'users':
    readers => "{ \"names\": [\"$couchdb_webapp_user\"], \"roles\": [] }",
    require => Couchdb::Query::Setup['localhost']
  }

  couchdb::create_db { 'tokens':
    readers => "{ \"names\": [], \"roles\": [\"auth\"] }",
    require => Couchdb::Query::Setup['localhost']
  }

  include site_shorewall::couchdb
  include site_shorewall::couchdb::bigcouch
}
