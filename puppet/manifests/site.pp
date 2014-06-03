# set a default exec path
Exec { path => '/usr/bin:/usr/sbin/:/bin:/sbin:/usr/local/bin:/usr/local/sbin' }


include site_config::setup
include site_config::default

# configure eip
if $services =~ /\bopenvpn\b/ {
  include site_openvpn
}

if $services =~ /\bcouchdb\b/ {
  include site_couchdb
  include tapicero
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

if $services =~ /\bstatic\b/ {
  include site_static
}

include site_config::packages::uninstall
