class site_couchdb {
  tag 'leap_service'

  $couchdb_config         = hiera('couch')
  $couchdb_users          = $couchdb_config['users']

  $couchdb_admin          = $couchdb_users['admin']
  $couchdb_admin_user     = $couchdb_admin['username']
  $couchdb_admin_pw       = $couchdb_admin['password']
  $couchdb_admin_salt     = $couchdb_admin['salt']

  $couchdb_leap_mx        = $couchdb_users['leap_mx']
  $couchdb_leap_mx_user   = $couchdb_leap_mx['username']
  $couchdb_leap_mx_pw     = $couchdb_leap_mx['password']
  $couchdb_leap_mx_salt   = $couchdb_leap_mx['salt']

  $couchdb_soledad        = $couchdb_users['soledad']
  $couchdb_soledad_user   = $couchdb_soledad['username']
  $couchdb_soledad_pw     = $couchdb_soledad['password']
  $couchdb_soledad_salt   = $couchdb_soledad['salt']

  $couchdb_tapicero        = $couchdb_users['tapicero']
  $couchdb_tapicero_user   = $couchdb_tapicero['username']
  $couchdb_tapicero_pw     = $couchdb_tapicero['password']
  $couchdb_tapicero_salt   = $couchdb_tapicero['salt']

  $couchdb_webapp         = $couchdb_users['webapp']
  $couchdb_webapp_user    = $couchdb_webapp['username']
  $couchdb_webapp_pw      = $couchdb_webapp['password']
  $couchdb_webapp_salt    = $couchdb_webapp['salt']

  $couchdb_backup         = $couchdb_config['backup']

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

  Class['site_config::default']
    -> Class['couchdb::bigcouch::package::cloudant']
    -> Service['couchdb']
    -> Class['site_couchdb::stunnel']
    -> File['/root/.netrc']
    -> Class['site_couchdb::bigcouch::add_nodes']
    -> Couchdb::Create_db['users']
    -> Couchdb::Create_db['tokens']
    -> Couchdb::Add_user[$couchdb_webapp_user]
    -> Couchdb::Add_user[$couchdb_soledad_user]

  class { 'site_couchdb::stunnel': }

  class { 'site_couchdb::bigcouch::add_nodes': }

  # /etc/couchdb/couchdb.netrc is deployed by couchdb::query::setup
  # we symlink this to /root/.netrc for couchdb_scripts (eg. backup)
  # and makes life easier for the admin (i.e. using curl/wget without
  # passing credentials)
  file { '/root/.netrc':
    ensure  => link,
    target  => '/etc/couchdb/couchdb.netrc',
    require => Couchdb::Query::Setup['localhost']
  }

  file { '/srv/leap/couchdb':
    ensure => directory
  }

  couchdb::query::setup { 'localhost':
    user  => $couchdb_admin_user,
    pw    => $couchdb_admin_pw,
  }

  include site_couchdb::create_dbs
  include site_couchdb::add_users
  include site_couchdb::designs
  include site_couchdb::logrotate

  include site_shorewall::couchdb
  include site_shorewall::couchdb::bigcouch

  vcsrepo { '/srv/leap/couchdb/scripts':
    ensure   => present,
    provider => git,
    source   => 'https://leap.se/git/couchdb_scripts',
    revision => 'origin/master',
    require  => File['/srv/leap/couchdb']
  }

  if $couchdb_backup { include site_couchdb::backup }
}
