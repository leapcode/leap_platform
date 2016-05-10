# remove leftovers on webapp nodes
class site_config::remove::webapp {
  tidy {
    '/etc/apache/sites-enabled/leap_webapp.conf':
      notify => Service['apache'];
  }
}
