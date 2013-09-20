class site_config::x509::client_ca {

  ##
  ## This is for the special CA that is used exclusively for generating
  ## client certificates by the webapp.
  ##

  $x509      = hiera('x509')
  $client_ca = $x509['client_ca_cert']

  x509::ca { $site_config::params::client_ca_name:
    content => $client_ca
  }
}
