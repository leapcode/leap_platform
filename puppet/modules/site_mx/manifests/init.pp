class site_mx {
  tag 'leap_service'
  Class['site_config::default'] -> Class['site_mx']

  include site_postfix::mx
  include site_mx::haproxy
  include site_shorewall::mx
  include site_shorewall::service::smtp
  include site_mx::couchdb
  include leap_mx
}
