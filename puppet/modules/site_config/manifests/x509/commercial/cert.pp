class site_config::x509::commercial::cert {

  include ::site_config::params

  $x509      = hiera('x509')
  $cert      = $x509['commercial_cert']
  $ca        = $x509['commercial_ca_cert']

  $cafile = "${cert}\n${ca}"

  x509::cert { $site_config::params::commercial_cert_name:
    content => $cafile
  }

}
