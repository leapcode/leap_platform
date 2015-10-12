# remove leftovers on monitoring nodes
class site_config::remove::monitoring {

  tidy {
    'checkmk_logwatch_spool':
      path    => '/var/lib/check_mk/logwatch',
      recurse => true,
      matches => '*tapicero.log'
  }
}
