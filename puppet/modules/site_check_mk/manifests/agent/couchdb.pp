class site_check_mk::agent::couchdb {

  # watch logs
  file { '/etc/check_mk/logwatch.d/bigcouch.cfg':
    source => 'puppet:///modules/site_check_mk/agent/logwatch/bigcouch.cfg',
  }
  concat::fragment { 'syslog_couchdb':
    source  => 'puppet:///modules/site_check_mk/agent/logwatch/syslog/couchdb.cfg',
    target  => '/etc/check_mk/logwatch.d/syslog.cfg',
    order   => '02';
  }


  # check bigcouch processes
  augeas {
    'Bigcouch_epmd_procs':
      incl    => '/etc/check_mk/mrpe.cfg',
      lens    => 'Spacevars.lns',
      changes => [
        'rm /files/etc/check_mk/mrpe.cfg/Bigcouch_epmd_procs',
        'set Bigcouch_epmd_procs \'/usr/lib/nagios/plugins/check_procs -w 1:1 -c 1:1 -a /opt/bigcouch/erts-5.9.1/bin/epmd\'' ];
    'Bigcouch_beam_procs':
      incl    => '/etc/check_mk/mrpe.cfg',
      lens    => 'Spacevars.lns',
      changes => [
        'rm /files/etc/check_mk/mrpe.cfg/Bigcouch_beam_procs',
        'set Bigcouch_beam_procs \'/usr/lib/nagios/plugins/check_procs -w 1:1 -c 1:1 -a /opt/bigcouch/erts-5.9.1/bin/beam\'' ];
  }

  # check open files for bigcouch proc
  include site_check_mk::agent::package::perl_plugin
  file { '/srv/leap/nagios/plugins/check_unix_open_fds.pl':
    source => 'puppet:///modules/site_check_mk/agent/nagios_plugins/check_unix_open_fds.pl',
    mode   => '0755'
  }
  augeas {
    'Bigcouch_open_files':
      incl    => '/etc/check_mk/mrpe.cfg',
      lens    => 'Spacevars.lns',
      changes => [
        'rm /files/etc/check_mk/mrpe.cfg/Bigcouch_open_files',
        'set Bigcouch_open_files \'/srv/leap/nagios/plugins/check_unix_open_fds.pl -a beam -w 28672,28672 -c 30720,30720\'' ];
  }

}
