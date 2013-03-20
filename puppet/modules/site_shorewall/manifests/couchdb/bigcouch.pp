class site_shorewall::couchdb::bigcouch inherits site_shorewall::couchdb {

  include site_shorewall::defaults

  create_resources(site_shorewall::dnat, hiera('shorewall_dnat'))

}
