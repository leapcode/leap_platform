class site_check_mk::agent::soledad {

  file { '/etc/check_mk/logwatch.d/soledad.cfg':
    source => 'puppet:///modules/site_check_mk/agent/logwatch/soledad.cfg',
  }

  # local nagios plugin checks via mrpe

  augeas { 'Soledad_Procs':
    incl    => '/etc/check_mk/mrpe.cfg',
    lens    => 'Spacevars.lns',
    changes => [
      'rm /files/etc/check_mk/mrpe.cfg/Soledad_Procs',
      'set Soledad_Procs \'/usr/lib/nagios/plugins/check_procs -w 1:1 -c 1:1 -a "/usr/bin/python /usr/bin/twistd --uid=soledad --gid=soledad --pidfile=/var/run/soledad.pid --logfile=/var/log/soledad.log web --wsgi=leap.soledad.server.application --port=ssl:2323:privateKey=/etc/x509/keys/leap.key:certKey=/etc/x509/certs/leap.crt:sslmethod=SSLv23_METHOD"\'' ]
  }
}
