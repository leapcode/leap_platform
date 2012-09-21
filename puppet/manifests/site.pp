define print() {
  notice("The value is: '${name}'")
}

node 'default' {
  $concat_basedir =  '/var/lib/puppet/modules/concat'
  include concat::setup

  $services=hiera_array('services')
  notice("Services for $fqdn: $services")

  if 'eip' in $services {
    $tor=hiera('tor')
    notice("Tor enabled: $tor")

    $openvpn_config=hiera('openvpn')
    create_resources('site_openvpn::server_config', $openvpn_config)
  }
}
