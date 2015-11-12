class site_config::x509::dkim::key {

  ##
  ## This is for the DKIM key that is used exclusively for DKIM
  ## signing

  $x509 = hiera('x509')
  $key  = $x509['dkim_key']

  x509::key { 'dkim':
    content => $key
  }
}
