class site_shorewall::webapp {

  include site_shorewall::defaults
  include site_shorewall::service::https
  include site_shorewall::service::http
  include site_shorewall::service::webapp_api
}
