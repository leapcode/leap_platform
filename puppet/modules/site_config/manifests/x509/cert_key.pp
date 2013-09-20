class site_config::x509::cert_key {

  $x509      = hiera('x509')
  $key       = $x509['key']
  $cert      = $x509['cert']

  x509::key { $site_config::params::cert_name:
    content => $key
  }

  x509::cert { $site_config::params::cert_name:
    content => $cert
  }

}
