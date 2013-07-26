# set a default exec path
Exec { path => '/usr/bin:/usr/sbin/:/bin:/sbin:/usr/local/bin:/usr/local/sbin' }

# parse services for host
$services=join(hiera_array('services'), ' ')
notice("Services for ${fqdn}: ${services}")

# make sure apt is updated before any packages are installed
include apt::update
Package { require => Exec['apt_updated'] }

include stdlib

include site_config::default
include site_config::slow


# configure eip
if $services =~ /\bopenvpn\b/ {
  include site_openvpn
}

if $services =~ /\bcouchdb\b/ {
  include site_couchdb
}

if $services =~ /\bwebapp\b/ {
  include site_webapp
  include site_nickserver
}

if $services =~ /\bsoledad\b/ {
  include soledad::server
}

if $services =~ /\bmonitor\b/ {
  include site_nagios
}

if $services =~ /\btor\b/ {
  include site_tor
}

if $services =~ /\bmx\b/ {
  include site_mx
}

