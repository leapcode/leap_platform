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
    'smtpd_tls_eecdh_grade':
      value => 'ultra'
  }

  # Setup DH parameters
  # Instead of using the dh parameters that are created by leap cli, it is more
  # secure to generate new parameter files that will only be used for postfix,
  # for each machine

  include site_config::packages::gnutls

  # Note, the file name is called dh_1024.pem, but we are generating 2048bit dh
  # parameters Neither Postfix nor OpenSSL actually care about the size of the
  # prime in "smtpd_tls_dh1024_param_file".  You can make it 2048 bits

  exec { 'certtool-postfix-gendh':
    command => 'certtool --generate-dh-params --bits 2048 --outfile /etc/postfix/smtpd_tls_dh_param.pem',
    user    => root,
    group   => root,
    creates => '/etc/postfix/smtpd_tls_dh_param.pem',
    require => [ Package['gnutls-bin'], Package['postfix'] ]
  }

  # Make sure the dh params file has correct ownership and mode
  file {
    '/etc/postfix/smtpd_tls_dh_param.pem':
      owner   => root,
      group   => root,
      mode    => '0600',
      require => Exec['certtool-postfix-gendh'];
  }

  postfix::config { 'smtpd_tls_dh1024_param_file':
    value   => '/etc/postfix/smtpd_tls_dh_param.pem',
    require => File['/etc/postfix/smtpd_tls_dh_param.pem']
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
    # see issue #4011
    'smtp_tls_protocols':
      value => '!SSLv2, !SSLv3';
  }


