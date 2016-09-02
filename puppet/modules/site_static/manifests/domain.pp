# configure static service for domain
define site_static::domain (
  $ca_cert,
  $key,
  $cert,
  $tls_only=true,
  $use_hidden_service=false,
  $locations=undef,
  $aliases=undef,
  $apache_config=undef) {

  $domain = $name
  $base_dir = '/srv/static'

  $cafile = "${cert}\n${ca_cert}"

  if is_hash($locations) {
    create_resources(site_static::location, $locations)
  }

  x509::cert { $domain:
    content => $cafile,
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
