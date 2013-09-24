class site_config::x509::client_ca::key {

  ##
  ## This is for the special CA that is used exclusively for generating
  ## client certificates by the webapp.
  ##

  $x509 = hiera('x509')
  $key  = $x509['client_ca_key']

  x509::key { $site_config::params::client_ca_name:
    content => $key
  }
}
