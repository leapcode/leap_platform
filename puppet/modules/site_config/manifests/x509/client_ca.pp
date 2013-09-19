class site_config::x509::client_ca {

  $x509      = hiera('x509')
  $client_ca = $x509['client_ca_cert']

  x509::ca { $site_config::params::client_ca_name:
    content => $client_ca
  }
}
