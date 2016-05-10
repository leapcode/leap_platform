# configure smtp tls
class site_postfix::mx::smtp_tls {

  include site_config::x509::ca
  include x509::variables
  $cert_name = hiera('name')
  $ca_path   = "${x509::variables::local_CAs}/${site_config::params::ca_name}.crt"
  $cert_path = "${x509::variables::certs}/${site_config::params::cert_name}.crt"
  $key_path  = "${x509::variables::keys}/${site_config::params::cert_name}.key"

  include site_config::x509::cert
  include site_config::x509::key

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
      value => "btree:\${data_directory}/smtp_cache";
    # see issue #4011
    'smtp_tls_protocols':
      value => '!SSLv2, !SSLv3';
    'smtp_tls_mandatory_protocols':
      value => '!SSLv2, !SSLv3';
    'tls_ssl_options':
      value => 'NO_COMPRESSION';
    # We can switch between the different postfix internal list of ciphers by
    # using smtpd_tls_ciphers.  For server-to-server connections we leave this
    # at its default because of opportunistic encryption combined with many mail
    # servers only support outdated protocols and ciphers and if we are too
    # strict with required ciphers, then connections *will* fall-back to
    # plain-text. Bad ciphers are still better than plain text transmission.
  }
}
