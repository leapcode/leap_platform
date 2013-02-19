class site_shorewall::monitor {

  include site_shorewall::defaults
  include site_shorewall::service::http
  include site_shorewall::service::https


}
