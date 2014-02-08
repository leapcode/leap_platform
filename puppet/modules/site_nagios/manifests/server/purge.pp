class site_nagios::server::purge inherits nagios::base {
  # we don't want to get /etc/nagios3 and /etc/nagios3/conf.d
  # purged, cause the check-mk-config-nagios3 package
  # places its templates in /etc/nagios3/conf.d/check_mk,
  # and check_mk -O updated it's nagios config in /etc/nagios3/conf.d/check_mk
  File['nagios_cfgdir'] {
    purge => false
  }
  File['nagios_confd'] {
    purge => false
  }

  exec {'purge_conf.d':
    command => '/bin/rm -f /etc/nagios3/conf.d/nagios_*',
    onlyif  => 'find /etc/nagios3/conf.d/ | grep -q "/etc/nagios3/conf.d/nagios_"'
  }
}
