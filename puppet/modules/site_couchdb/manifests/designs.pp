class site_couchdb::designs {

  Class['site_couchdb::create_dbs']
    -> Class['site_couchdb::designs']

  file { '/srv/leap/couchdb/designs':
    ensure  => directory,
    source  => 'puppet:///modules/site_couchdb/designs',
    recurse => true,
    mode    => '0755'
  }

  exec { '/srv/leap/couchdb/scripts/load_design_documents.sh':
    subscribe   => File['/srv/leap/couchdb/designs'],
    refreshonly => true,
    require     => Vcsrepo['/srv/leap/couchdb/scripts']
  }

}

