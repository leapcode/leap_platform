define print() {
   notice("The value is: '${name}'")
}
 

node 'default' {
  #$password=hiera('testpw')
  #notify {"Password: $password":}

  $services=hiera_array('services')
  notice("Services for $fqdn: $services")

  if 'eip' in $services {
    $openvpn_ports=hiera_array('openvpn_ports')
    $tor=hiera('tor')
    notice("Openvpn Config for $fqdn: openvpn_ports=$openvpn_ports, tor=$tor")
    print{$openvpn_ports:}
    #include site_openvpn
  }


}
