class site_config::x509::ca_bundle {

  $x509      = hiera('x509')
  $ca        = $x509['ca_cert']
  $client_ca = $x509['client_ca_cert']

  x509::ca { $site_config::params::ca_bundle_name:
    content => "${ca}${client_ca}"
  }
}
