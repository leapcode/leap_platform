class site_shorewall::couchdb::bigcouch {

  include site_shorewall::defaults

  create_resources(site_shorewall::dnat, hiera('shorewall_dnat'))

}
