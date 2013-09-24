class site_postfix::mx::smtp_auth {

  postfix::config {
    'smtpd_tls_ask_ccert': value => 'yes';
  }
}
