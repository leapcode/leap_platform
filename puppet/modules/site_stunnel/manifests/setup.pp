class site_stunnel::setup ($cert_name, $key, $cert, $ca) {

  include x509::variables
  include site_stunnel

  $ca_name   = 'leap_ca'
  $ca_path   = "${x509::variables::local_CAs}/${ca_name}.crt"
  $cert_path = "${x509::variables::certs}/${cert_name}.crt"
  $key_path  = "${x509::variables::keys}/${cert_name}.key"

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

  x509::ca {
    $ca_name:
      content => $ca,
      notify  => Service['stunnel'];
  }

}

