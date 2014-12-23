class site_postfix::mx::smtp_tls {

  include site_config::x509::ca
  include x509::variables
  $ca_path   = "${x509::variables::local_CAs}/${site_config::params::ca_name}.crt"
  $cert_path = "${x509::variables::certs}/${site_config::params::cert_name}.crt"
  $key_path  = "${x509::variables::keys}/${site_config::params::cert_name}.key"

  # smtp TLS
  postfix::config {
    'smtp_use_tls':        value  => 'yes';
    'smtp_tls_CApath':     value  => '/etc/ssl/certs/';
    'smtp_tls_CAfile':     value  => $ca_path;
    'smtp_tls_cert_file':  value  => $cert_path;
    'smtp_tls_key_file':   value  => $key_path;
    'smtp_tls_loglevel':   value  => '1';
    'smtp_tls_exclude_ciphers':
      value => 'aNULL, MD5, DES';
    # upstream default is md5 (since 2.5 and older used it), we force sha1
    'smtp_tls_fingerprint_digest':
      value => 'sha1';
    'smtp_tls_session_cache_database':
      value => 'btree:${data_directory}/smtp_cache';
    # see issue #4011
    'smtp_tls_protocols':
      value => '!SSLv2, !SSLv3';
  }
}
