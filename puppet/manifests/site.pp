define print() {
  notice("The value is: '${name}'")
}

define create_openvpn_config($port, $protocol) {
  $openvpn_configname=$name
  notice("Creating OpenVPN $openvpn_configname:  
    Port: $port, Protocol: $protocol")
  # ...
  #include site_openvpn

}

node 'default' {
  #$password=hiera('testpw')
  #notify {"Password: $password":}

  $services=hiera_array('services')
  notice("Services for $fqdn: $services")

  if 'eip' in $services {
    $openvpn=hiera('openvpn')
    $tor=hiera('tor')
    notice("Tor enabled: $tor")
    create_resources('create_openvpn_config', $openvpn)
  }
}
