class site_squid_deb_proxy::client {
  include squid_deb_proxy::client
  include site_shorewall::defaults
  include shorewall::rules::mdns
}
