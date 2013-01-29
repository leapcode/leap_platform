# set a default exec path
Exec { path => '/usr/bin:/usr/sbin/:/bin:/sbin:/usr/local/bin:/usr/local/sbin' }

stage { 'initial':
  before => Stage['main'],
}

node 'default' {
  # prerequisites
  import 'common'
  include concat::setup

  $development = hiera('development')
  if $development['site_config'] == true {
    # include some basic classes
    include site_config
  } else {
    notice ('NOT applying site_config')
  }

  # parse services for host
  $services=hiera_array('services')
  notice("Services for $fqdn: $services")

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
}
