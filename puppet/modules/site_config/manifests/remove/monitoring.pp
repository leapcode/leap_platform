# remove leftovers on monitoring nodes
class site_config::remove::monitoring {

  # Remove check_mk loggwatch spoolfiles for
  # tapicero and bigcouch
  tidy {
    'remove_logwatch_spoolfiles':
      path    => '/var/lib/check_mk/logwatch',
      recurse => true,
      matches => [ '*tapicero.log', '*bigcouch.log'];
  }

}
