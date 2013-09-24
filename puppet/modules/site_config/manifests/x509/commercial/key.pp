class site_config::x509::commercial::key {

  $x509      = hiera('x509')
  $key       = $x509['commercial_key']

  x509::key { $site_config::params::commercial_cert_name:
    content => $key
  }
}
