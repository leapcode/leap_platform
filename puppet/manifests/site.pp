node 'default' {
  # $concat_basedir =  '/var/lib/puppet/modules/concat'  # do we need this ?
  include concat::setup

  $services=hiera_array('services')
  notice("Services for $fqdn: $services")

  if 'eip' in $services {
    include site_openvpn

    $tor=hiera('tor')
    notice("Tor enabled: $tor")

    $openvpn_configs=hiera('openvpn_server_configs')
    create_resources('site_openvpn::server_config', $openvpn_configs)

  }
}
