class site_postfix::mx::smtp_auth {
  $x509 = hiera('x509')

  postfix::config {
    'smtpd_tls_cert_file': value => $x509['client_ca_cert'];
    'smtpd_tls_key_file':  value => $x509['client_ca_key'];
    'smtpd_tls_ask_ccert': value => 'yes';
    #'smtpd_tls_CAfile':    value =>
  }
}
