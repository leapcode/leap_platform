class site_couchdb::configure {


  file { '/etc/couchdb/local.d/admin.ini':
    content => "[admins]
admin = $site_couchdb::couchdb_admin_pw
",
    mode    => '0600',
    owner   => 'couchdb',
    group   => 'couchdb',
    notify  => Service[couchdb]
  }


  exec { '/etc/init.d/couchdb restart; sleep 6':
    path        => ['/bin', '/usr/bin',],
    subscribe   => File['/etc/couchdb/local.d/admin.ini',
      '/etc/couchdb/local.ini'],
    refreshonly => true
  }
}
