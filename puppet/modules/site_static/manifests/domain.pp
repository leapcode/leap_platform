define site_static::domain (
  $locations,
  $ca_cert,
  $key,
  $cert,
  $tls_only) {

  create_resources(site_static::location, $locations)
}
