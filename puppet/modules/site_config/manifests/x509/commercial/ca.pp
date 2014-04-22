class site_config::x509::commercial::ca {

  $x509      = hiera('x509')
  $ca        = $x509['commercial_ca_cert']

  x509::ca { $site_config::params::commercial_ca_name:
    content => $ca
  }
}
