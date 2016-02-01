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
}
