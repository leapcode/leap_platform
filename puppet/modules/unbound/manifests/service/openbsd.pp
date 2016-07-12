# == Class: unbound::service::openbsd
#
# Service things specific for OpenBSD.  Sets the unbound_flags variable in
# /etc/rc.conf.local, and appends the path to the log device to syslogd_flags.
#
# === Examples
#
# include unbound::service::openbsd
#
class unbound::service::openbsd {
  rcconf { 'unbound_flags':
    value => $unbound::params::unbound_flags,
  }

  # syslogd_flags needs one -a dir per chrooted service.  Each can be a separate
  # line, so don't use rcconf.
  file_line { 'unbound syslogd_flags':
      path => '/etc/rc.conf.local',
      line => "syslogd_flags=\"\${syslogd_flags} -a ${unbound::params::logfile}\"";
  }
}
