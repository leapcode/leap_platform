class site_config::x509 {

  $x509      = hiera('x509')
  $key       = $x509['key']
  $cert      = $x509['cert']
  $ca        = $x509['ca_cert']
  $client_ca = $x509['client_ca_cert']

  x509::key { $site_config::params::cert_name:
    content => $key
  }

  x509::cert { $site_config::params::cert_name:
    content => $cert
  }

  x509::ca { $site_config::params::ca_name:
    content => $ca
  }

  x509::ca { $site_config::params::ca_bundle_name:
    content => "${ca}${client_ca}"
  }
}
