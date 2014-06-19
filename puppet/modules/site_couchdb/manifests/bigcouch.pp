class site_couchdb::bigcouch {

  $bigcouch_config         = $couchdb_config['bigcouch']
  $bigcouch_cookie         = $bigcouch_config['cookie']

  $ednp_port               = $bigcouch_config['ednp_port']

  Class['site_config::default']
    -> Class['site_couchdb::bigcouch::add_nodes']
    -> Class['site_couchdb::bigcouch::settle_cluster']

  include site_couchdb::bigcouch::add_nodes
  include site_couchdb::bigcouch::settle_cluster
  include site_couchdb::bigcouch::compaction
  include site_shorewall::couchdb::bigcouch

  file { '/var/log/bigcouch':
    ensure => directory
  }
}
