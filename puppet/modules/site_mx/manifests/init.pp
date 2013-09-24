class site_mx {
  tag 'leap_service'
  Class['site_config::default'] -> Class['site_mx']

  include site_config::x509::cert
  include site_config::x509::key
  include site_config::x509::ca
  include site_config::x509::client_ca::ca
  include site_config::x509::client_ca::key


  include site_postfix::mx
  include site_mx::haproxy
  include site_shorewall::mx
  include site_shorewall::service::smtp
  include site_mx::couchdb
  include leap_mx
}
