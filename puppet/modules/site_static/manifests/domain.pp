define site_static::domain (
  $ca_cert,
  $key,
  $cert,
  $tls_only=true,
  $locations=undef,
  $aliases=undef,
  $apache_config=undef) {

  $domain = $name
  $base_dir = '/srv/static'

  create_resources(site_static::location, $locations)

  x509::cert { $domain:
    content => $cert,
    notify => Service[apache]
  }
  x509::key { $domain:
    content => $key,
    notify => Service[apache]
  }
  x509::ca { "${domain}_ca":
    content => $ca_cert,
    notify => Service[apache]
  }

  apache::vhost::file { $domain:
    content => template('site_static/apache.conf.erb')
  }

}
