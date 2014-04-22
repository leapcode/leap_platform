class site_couchdb::bigcouch::settle_cluster {

  exec { 'wait_for_couch_nodes':
    command => '/srv/leap/bin/run_tests --test CouchDB/Are_configured_nodes_online? --retry 6 --wait 10'
  }

  exec { 'settle_cluster_membership':
    command => '/srv/leap/bin/run_tests --test CouchDB/Is_cluster_membership_ok? --retry 6 --wait 10',
    require => Exec['wait_for_couch_nodes']
  }
}
