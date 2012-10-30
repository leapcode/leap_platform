class site_couchdb::configure {
  #Class[site_couchdb::package] -> Class[site_couchdb::configure] 
  class { 'couchdb':
    #bind => '0.0.0.0'
  }

}
