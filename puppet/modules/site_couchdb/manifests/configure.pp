class site_couchdb::configure {
  Class[site_couchdb::package] -> Class[couchdb]

  class { 'couchdb':
    require => Class['site_couchdb::package'], }


  file { '/etc/init.d/couchdb':
    source => 'puppet:///modules/site_couchdb/couchdb',
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
  }

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
