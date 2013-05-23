class site_couchdb::bigcouch::add_nodes {
  # loop through neighbors array and add nodes
  $nodes = $::site_couchdb::bigcouch_config['neighbors']
  couchdb::bigcouch::add_node { $nodes: }
}
