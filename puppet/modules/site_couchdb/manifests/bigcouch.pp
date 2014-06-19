class site_couchdb::bigcouch {

  $config         = $::site_couchdb::couchdb_config['bigcouch']
  $cookie         = $config['cookie']

  $ednp_port               = $config['ednp_port']

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
