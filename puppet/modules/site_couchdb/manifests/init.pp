class site_couchdb {

  # install couchdb package first, then configure it
  
  Class[site_couchdb::package] -> Class[site_couchdb::configure]

  include site_couchdb::package
  include site_couchdb::configure

}
