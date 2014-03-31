define site_static::domain (
  $locations,
  $ca_cert,
  $key,
  $cert,
  $tls_only) {

  $domain = $name
  $base_dir = '/srv/static'

  create_resources(site_static::location, $locations)

  x509::cert { $domain: content => $cert }
  x509::key  { $domain: content => $key }
  x509::ca   { "${domain}_ca": content => $ca_cert }

  class { '::apache': no_default_site => true, ssl => true }
  include site_apache::module::headers
  include site_apache::module::alias
  include site_apache::module::expires
  include site_apache::module::removeip
  include site_apache::module::rewrite

  apache::vhost::file { $domain:
    content => template('site_static/apache.conf.erb')
  }

}
