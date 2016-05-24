class couchdb::deploy_config {

  file { '/etc/couchdb/local.ini':
    source  => [ "puppet:///modules/site_couchdb/${::fqdn}/local.ini",
                'puppet:///modules/site_couchdb/local.ini',
                'puppet:///modules/couchdb/local.ini' ],
    notify  => Service[couchdb],
    owner   => couchdb,
    group   => couchdb,
    mode    => '0660'
  }
}
