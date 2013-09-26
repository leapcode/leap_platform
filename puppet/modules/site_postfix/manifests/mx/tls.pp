class site_postfix::mx::tls {

  include x509::variables
  $ca_path   = "${x509::variables::local_CAs}/${site_config::params::client_ca_name}.crt"
  $cert_path = "${x509::variables::certs}/${site_config::params::cert_name}.crt"
  $key_path  = "${x509::variables::keys}/${site_config::params::cert_name}.key"


  postfix::config {
    'smtpd_use_tls':        value  => 'yes';
    'smtpd_tls_CAfile':     value  => $ca_path;
    'smtpd_tls_cert_file':  value  => $cert_path;
    'smtpd_tls_key_file':   value  => $key_path;
    'smtpd_tls_ask_ccert':  value  => 'yes';
    'smtpd_tls_security_level':
      value  => 'may';
  }

}
  # smtp TLS
  postfix::config {
    'smtp_use_tls':        value  => 'yes';
    'smtp_tls_CApath':     value  => '/etc/ssl/certs/';
    'smtp_tls_CAfile':     value  => $ca_path;
    'smtp_tls_cert_file':  value  => $cert_path;
    'smtp_tls_key_file':   value  => $key_path;
    'smtp_tls_ask_ccert':  value  => 'yes';
    'smtp_tls_loglevel':   value  => '1';
    'smtp_tls_exclude_ciphers':
      value => 'aNULL, MD5, DES';
    # upstream default is md5 (since 2.5 and older used it), we force sha1
    'smtp_tls_fingerprint_digest':
      value => 'sha1';
    'smtp_tls_session_cache_database':
      value => 'btree:${queue_directory}/smtp_cache';
    'smtp_tls_security_level':
      value  => 'may';
  }


