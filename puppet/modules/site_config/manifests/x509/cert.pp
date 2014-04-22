class site_config::x509::cert {

  $x509      = hiera('x509')
  $cert      = $x509['cert']

  x509::cert { $site_config::params::cert_name:
    content => $cert
  }

}
