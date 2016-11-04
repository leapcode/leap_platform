define couchdb::bigcouch::add_node {

  couchdb::bigcouch::document { "add_${name}":
    db   => 'nodes',
    id   => "bigcouch@${name}",
    ensure => 'present'
  }
}
