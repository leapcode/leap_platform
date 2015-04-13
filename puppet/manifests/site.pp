# set a default exec path
# the logoutput exec parameter defaults to "on_error" in puppet 3,
# but to "false" in puppet 2.7, so we need to set this globally here
Exec {
  logoutput => on_failure,
  path      => '/usr/bin:/usr/sbin/:/bin:/sbin:/usr/local/bin:/usr/local/sbin'
}


$services = hiera('services', [])
$services_str = join($services, ', ')
notice("Services for ${fqdn}: ${services_str}")

if member($services, 'openvpn') {
  include site_openvpn
}

if member($services, 'couchdb') {
  include site_couchdb
}

if member($services, 'webapp') {
  include site_webapp
}

if member($services, 'soledad') {
  include soledad::server
}

if member($services, 'monitor') {
  include site_nagios
}

if member($services, 'tor') {
  include site_tor
}

if member($services, 'mx') {
  include site_mx
}

if member($services, 'static') {
  include site_static
}

if member($services, 'obfsproxy') {
  include site_obfsproxy
}
