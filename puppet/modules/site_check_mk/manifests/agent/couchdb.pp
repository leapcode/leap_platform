class site_check_mk::agent::couchdb {

  # local custom checks
  file { '/usr/lib/check_mk_agent/local/check_bigcouch_errors.sh':
    ensure  => link,
    target  => '/srv/leap/couchdb/scripts/tests/check_bigcouch_errors.sh',
    require => Vcsrepo['/srv/leap/couchdb/scripts']
  }

  # local nagios plugin checks via mrpe
  file_line {
    'Tapicero_Procs':
      line => 'Tapicero_Procs  /usr/lib/nagios/plugins/check_procs -w 1:1 -c 1:1 -a tapicero',
      path => '/etc/check_mk/mrpe.cfg';
  }

}
