class site_config::x509::commercial::cert {

  $x509      = hiera('x509')
  $cert      = $x509['commercial_cert']

  x509::cert { $site_config::params::commercial_cert_name:
    content => $cert
  }

}
