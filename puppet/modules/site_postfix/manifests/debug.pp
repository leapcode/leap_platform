class site_postfix::debug {

  postfix::config {
    'debug_peer_list':      value => '127.0.0.1';
    'debug_peer_level':     value => '1';
    'smtpd_tls_loglevel':   value => '1';
  }

}
