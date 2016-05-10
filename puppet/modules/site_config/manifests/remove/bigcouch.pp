# remove bigcouch leftovers from previous installations
class site_config::remove::bigcouch {

  # Don't use check_mk logwatch to watch bigcouch logs anymore
  # see https://leap.se/code/issues/7375 for more details
  file { '/etc/check_mk/logwatch.d/bigcouch.cfg':
    ensure => absent,
    notify => [
      Exec['remove_bigcouch_logwatch_stateline']
    ]
  }

  exec { 'remove_bigcouch_logwatch_stateline':
    command     => "sed -i '/bigcouch.log/d' /etc/check_mk/logwatch.state",
    refreshonly => true,
  }

  cron { 'compact_all_shards':
    ensure => absent
  }


  exec { 'kill_bigcouch_stunnel_procs':
    refreshonly => true,
    command     => '/usr/bin/pkill -f "/usr/bin/stunnel4 /etc/stunnel/(ednp|epmd)_server.conf"'
  }

  # 'tidy' doesn't notify other resources, so we need to use file here instead
  # see https://tickets.puppetlabs.com/browse/PUP-6021
  file {
    [ '/etc/stunnel/ednp_server.conf', '/etc/stunnel/epmd_server.conf']:
      ensure => absent,
      # notifying Service[stunnel] doesn't work here because the config
      # files contain the pid of the procs to stop/start.
      # If we remove the config, and restart stunnel then it will only
      # stop/start the procs for which config files are found and the stale
      # service will continue to run.
      # So we simply kill them.
      notify => Exec['kill_bigcouch_stunnel_procs']
  }

}
