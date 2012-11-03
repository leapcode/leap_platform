class site_couchdb::configure {
  Class[site_couchdb::package] -> Class[couchdb]

  class { 'couchdb':
    require => Class['site_couchdb::package'],
  }

  $adminpw = hiera('couchdb_adminpw')
  file { '/etc/couchdb/local.d/admin.ini':
    content => "[admins]
admin = $adminpw
",
    mode    => '0600',
    owner   => 'couchdb',
    group   => 'couchdb',
    notify  => Service[couchdb]
  }
}
