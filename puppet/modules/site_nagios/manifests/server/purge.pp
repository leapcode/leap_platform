class site_nagios::server::purge {
  exec {'purge_conf.d':
    command => '/bin/rm -rf /etc/nagios3/conf.d/*',
    onlyif  => 'test -e /etc/nagios3/conf.d'
  }

}
