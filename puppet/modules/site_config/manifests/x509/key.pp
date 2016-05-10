class site_config::x509::key {

  include ::site_config::params

  $x509      = hiera('x509')
  $key       = $x509['key']

  x509::key { $site_config::params::cert_name:
    content => $key
  }
}
