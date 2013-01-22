##
## This is for the special CA that is used exclusively for generating
## client certificates by the webapp.
##

class site_webapp::client_ca {
  include x509::variables

  $x509 = hiera('x509')
  $cert_path = "${x509::variables::certs}/leap_client_ca.crt"
  $key_path = "${x509::variables::keys}/leap_client_ca.key"

  x509::key {
    'leap_client_ca':
      source => $x509['client_ca_key'],
      notify  => Service[apache];
  }

  x509::cert {
    'leap_client_ca':
      source => $x509['client_ca_cert'],
      notify  => Service[apache];
  }
}
