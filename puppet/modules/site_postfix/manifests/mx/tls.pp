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

  exec { 'certtool-postfix-gendh-1024':
    command => 'certtool --generate-dh-params --bits=1024 --outfile=/etc/postfix/dh_1024.pem',
    user    => root,
    group   => root,
    creates => '/etc/postfix/dh_1024.pem',
    require => Package['gnutls-bin']
  }

  # Make sure the dh params file has correct ownership and mode
  file {
    '/etc/postfix/dh_1024.pem':
      owner   => root,
      group   => root,
      mode    => '0600',
      require => Exec['certtool-postfix-gendh-1024'];
  }

  postfix::config { 'smtpd_tls_dh1024_param_file':
    value   => '/etc/postfix/dh_1024.pem',
    require => File['/etc/postfix/dh_1024.pem']
  }

}
