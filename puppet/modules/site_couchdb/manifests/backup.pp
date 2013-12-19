class site_couchdb::backup {

  # general backupninja config
  backupninja::config { 'backupninja_config':
    usecolors     => false,
  }

  # dump all DBs locally to /var/backups/couchdb once a day
  backupninja::sh { 'couchdb_backup':
    command_string => "cd /srv/leap/couchdb/scripts \n./couchdb_dumpall.sh"
  }

  # Deploy /etc/leap/couchdb_scripts_defaults.conf so we can exclude
  # some databases

  file { '/etc/leap/couchdb_scripts_defaults.conf':
    source => 'puppet:///modules/site_couchdb/couchdb_scripts_defaults.conf',
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
  }

}
