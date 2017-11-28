# configure static service for domain
define site_static::domain (
  $ca_cert=undef,
  $key,
  $cert,
  $tls_only=true,
  $use_hidden_service=false,
  $locations=undef,
  $aliases=undef,
  $apache_config=undef,
  $www_alias=false) {

  $domain = $name
  $base_dir = '/srv/static'

  if ($ca_cert) {
    $certfile = "${cert}\n${ca_cert}"
  } else {
    $certfile = $cert
  }

  if is_hash($locations) {
    create_resources(site_static::location, $locations)
  }

  x509::cert { $domain:
    content => $certfile,
    notify  => Service[apache]
  }
  x509::key { $domain:
    content => $key,
    notify  => Service[apache]
  }

  apache::vhost::file { $domain:
    content => template('site_static/apache.conf.erb')
  }

}
