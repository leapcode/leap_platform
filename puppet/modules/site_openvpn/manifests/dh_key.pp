class site_openvpn::dh_key {

  $x509_config      = hiera('x509')

  file { '/etc/openvpn/keys/dh.pem':
    content => $x509_config['dh'],
    mode    => '0644',
  }

}
