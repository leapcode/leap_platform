class site_couchdb {

  class {'site_couchdb::package':} -> class {'site_couchdb::configure':}

}
