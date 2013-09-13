define site_stunnel::setup ($cert_name, $key, $cert, $ca_name, $ca) {

  include site_stunnel

  x509::key {
    $cert_name:
      content => $key,
      notify  => Service['stunnel'];
  }

  x509::cert {
    $cert_name:
      content => $cert,
      notify  => Service['stunnel'];
  }

}

