# configure smtpd tls
class site_postfix::mx::smtpd_tls {

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
    'smtpd_tls_received_header':
      value => 'yes';
    'smtpd_tls_security_level':
      value  => 'may';
    'smtpd_tls_eecdh_grade':
      value => 'ultra';
    'smtpd_tls_session_cache_database':
      value => "btree:\${data_directory}/smtpd_scache";
    # see issue #4011
    'smtpd_tls_mandatory_protocols':
      value => '!SSLv2, !SSLv3';
    'smtpd_tls_protocols':
      value => '!SSLv2, !SSLv3';
    # For connections to MUAs, TLS is mandatory and the ciphersuite is modified.
    # MX and SMTP client configuration
    'smtpd_tls_mandatory_ciphers':
      value => 'high';
    'tls_high_cipherlist':
      value => 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!3DES:!RC4:!MD5:!PSK!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA';
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
