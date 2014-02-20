class site_check_mk::agent::logwatch {
  # Deploy mk_logwatch 1.2.4 so we can split the config
  # into multiple config files in /etc/check_mk/logwatch.d
  # see https://leap.se/code/issues/5135

  file { '/usr/lib/check_mk_agent/plugins/mk_logwatch':
    source => 'puppet:///modules/site_check_mk/agent/plugins/mk_logwatch.1.2.4',
    mode   => '0755'
  }

  # only config files that watch a distinct logfile should go in logwatch.d/
  file { '/etc/check_mk/logwatch.d':
    ensure  => directory,
    recurse => true,
    purge   => true,
  }

  # service that share a common logfile (i.e. /var/log/syslog) need to get
  # concanated in one file, otherwise the last file sourced will override
  # the config before
  # see mk_logwatch: "logwatch.cfg overwrites config files in logwatch.d",
  # https://leap.se/code/issues/5155

  # first, we need to deploy a custom logwatch.cfg that doesn't include
  # a section about /var/log/syslog

  file { '/etc/check_mk/logwatch.cfg':
    source  => 'puppet:///modules/site_check_mk/agent/logwatch/logwatch.cfg',
    require => Package['check_mk-agent-logwatch']
  }

  include concat::setup
  include site_check_mk::agent::logwatch::syslog
}
