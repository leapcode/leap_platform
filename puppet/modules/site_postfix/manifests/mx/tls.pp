class site_postfix::mx::tls {

  $x509                = hiera('x509')
  $key                 = $x509['key']
  $cert                = $x509['cert']
  $client_ca           = $x509['client_ca_cert']

  include x509::variables
  $cert_name = hiera('name')
  $cert_path = "${x509::variables::certs}/${cert_name}.crt"
  $key_path  = "${x509::variables::keys}/${cert_name}.key"

  x509::key { $cert_name:
    content => $key,
  }

  x509::cert { $cert_name:
    content => $cert,
  }

  postfix::config {
    'smtpd_use_tls':        value  => 'yes';
    'smtpd_tls_CAfile':     value  => $client_ca;
    'smtpd_tls_cert_file':  value  => $cert_path;
    'smtpd_tls_key_file':   value  => $key_path;
    'smtpd_tls_req_ccert':  value  => 'yes';
    'smtpd_tls_security_level':
      value  => 'encrypt';
  }

}
