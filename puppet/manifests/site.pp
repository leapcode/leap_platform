node 'default' {
  $service='eip'
  $password=hiera('testpw')
  $openvpn_ports=hiera_array('openvpn_ports')
  $tor=hiera('tor')
  notify {"Password: $password":}
  notify {"Openvpn Config for $fqdn: openvpn_ports=$openvpn_ports, tor=$tor":}
  #include site_openvpn

}
