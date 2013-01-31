# set a default exec path
Exec { path => '/usr/bin:/usr/sbin/:/bin:/sbin:/usr/local/bin:/usr/local/sbin' }

stage { 'initial':
  before => Stage['main'],
}

# prerequisites
import 'common'
include concat::setup
include site_config::default
include site_config::slow

# parse services for host
$services=hiera_array('services')
notice("Services for ${fqdn}: ${services}")

# configure eip
if 'openvpn' in $services {
  include site_openvpn
}

if 'couchdb' in $services {
  include site_couchdb
}

if 'webapp' in $services {
  include site_webapp
}

if 'ca' in $services {
  include site_ca_daemon
}

if 'monitor' in $services {
  include site_nagios::server
}
