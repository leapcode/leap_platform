class site_couchdb::bigcouch {

  $config         = $::site_couchdb::couchdb_config['bigcouch']
  $cookie         = $config['cookie']
  $ednp_port      = $config['ednp_port']

  class { 'couchdb':
    admin_pw            => $::site_couchdb::couchdb_admin_pw,
    admin_salt          => $::site_couchdb::couchdb_admin_salt,
    bigcouch            => true,
    bigcouch_cookie     => $cookie,
    ednp_port           => $ednp_port,
    chttpd_bind_address => '127.0.0.1'
  }

  #
  # stunnel must running correctly before bigcouch dbs can be set up.
  #
  Class['site_config::default']
    -> Class['couchdb::bigcouch::package::cloudant']
    -> Service['shorewall']
    -> Service['stunnel']
    -> Class['site_couchdb::setup']
    -> Class['site_couchdb::bigcouch::add_nodes']
    -> Class['site_couchdb::bigcouch::settle_cluster']

  include site_couchdb::bigcouch::add_nodes
  include site_couchdb::bigcouch::settle_cluster
  include site_couchdb::bigcouch::compaction

  file { '/var/log/bigcouch':
    ensure => directory
  }
}
