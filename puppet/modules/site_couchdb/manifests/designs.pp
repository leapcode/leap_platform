class site_couchdb::designs {

  Class['site_couchdb::create_dbs']
    -> Class['site_couchdb::designs']

  file { '/srv/leap/couchdb/designs':
    ensure  => directory,
    source  => 'puppet:///modules/site_couchdb/designs',
    recurse => true,
    purge   => true,
    mode    => '0755'
  }

  exec { '/srv/leap/couchdb/scripts/load_design_documents.sh':
    require     => Vcsrepo['/srv/leap/couchdb/scripts'],
    refreshonly => false
  }

}

