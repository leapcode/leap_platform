# remove leftovers on monitoring nodes
class site_config::remove::monitoring {

  tidy {
    'checkmk_logwatch_spool':
      path    => '/var/lib/check_mk/logwatch',
      recurse => true,
      matches => '*tapicero.log'
  }

  # remove leftover bigcouch logwatch spool files
  exec { 'remove_bigcouch_logwatch_spoolfiles':
    command     => 'find /var/lib/check_mk/logwatch -name \'\\opt\\bigcouch\\var\\log\\bigcouch.log\' -exec rm {} \;',
    refreshonly => true,
  }

}
