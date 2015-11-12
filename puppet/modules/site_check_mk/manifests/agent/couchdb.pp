# configure logwatch and nagios checks for couchdb (both bigcouch and plain
# couchdb installations)
class site_check_mk::agent::couchdb {

  concat::fragment { 'syslog_couchdb':
    source  => 'puppet:///modules/site_check_mk/agent/logwatch/syslog/couchdb.cfg',
    target  => '/etc/check_mk/logwatch.d/syslog.cfg',
    order   => '02';
  }

  # check different couchdb stats
  file { '/usr/lib/check_mk_agent/local/leap_couch_stats.sh':
    source  => 'puppet:///modules/site_check_mk/agent/local_checks/couchdb/leap_couch_stats.sh',
    mode    => '0755',
    require => Package['check_mk-agent']
  }

  # check open files for bigcouch proc
  include site_check_mk::agent::package::perl_plugin
  file { '/srv/leap/nagios/plugins/check_unix_open_fds.pl':
    source => 'puppet:///modules/site_check_mk/agent/nagios_plugins/check_unix_open_fds.pl',
    mode   => '0755'
  }
  augeas {
    'Couchdb_open_files':
      incl    => '/etc/check_mk/mrpe.cfg',
      lens    => 'Spacevars.lns',
      changes => [
        'rm /files/etc/check_mk/mrpe.cfg/Couchdb_open_files',
        'set Couchdb_open_files \'/srv/leap/nagios/plugins/check_unix_open_fds.pl -a beam -w 28672,28672 -c 30720,30720\'' ],
      require => File['/etc/check_mk/mrpe.cfg'];
  }

}
