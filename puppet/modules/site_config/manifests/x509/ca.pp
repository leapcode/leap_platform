class site_config::x509::ca {

  include ::site_config::params

  $x509      = hiera('x509')
  $ca        = $x509['ca_cert']

  x509::ca { $site_config::params::ca_name:
    content => $ca
  }
}
