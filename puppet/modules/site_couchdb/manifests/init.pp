class site_couchdb {

  $couchdb_config = hiera('couchdb')
  $key            = $couchdb_config['key']
  $cert           = $couchdb_config['crt']

  # install couchdb package first, then configure it
  Class['site_couchdb::package'] -> Class['site_couchdb::configure']

  include site_couchdb::package
  include site_couchdb::configure


  couchdb::ssl::deploy_cert { 'cert':
    key  => $key,
    cert => $cert,
  }
  include couchdb::deploy_config
}
