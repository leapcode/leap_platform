class site_couchdb::configure {
  Class[site_couchdb::package] -> Class[couchdb] 
  class { 'couchdb':
    require => Class['site_couchdb::package']
    #bind => '0.0.0.0'
  }
}
