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

  $adminpw = $site_couchdb::adminpw
  file { '/etc/couchdb/local.d/admin.ini':
    content => "[admins]
admin = $adminpw
",
    mode    => '0600',
    owner   => 'couchdb',
    group   => 'couchdb',
    notify  => Service[couchdb]
  }


  exec { '/etc/init.d/couchdb restart; sleep 3':
    path        => ['/bin', '/usr/bin',],
    subscribe   => File['/etc/couchdb/local.d/admin.ini',
      '/etc/couchdb/local.ini'],
    refreshonly => true
  }
}
