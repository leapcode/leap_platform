node 'default' {
  # prerequisites
  import 'common'
  include concat::setup

  # include some basic classes
  include site_config

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
    include site_ca
  }
}
