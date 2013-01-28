define site_nagios::add_service ($hostname, $ip_address, $service) {

  case $service {
    # don't deploy until we fix 1546
    #'openvpn': {
    #  $check_command       = "check_openvpn_server_ip_port!$ip_address!1194"
    #  $service_description = 'Openvpn'
    #}
    'webapp': {
      $check_command       = 'check_https'
      $service_description = 'Website'
    }
    default:  {
      #notice ("No Nagios service check for service \"$service\"")
    }
  }

  if ( $check_command != '' ) {
    nagios_service { $name:
      use                 => 'generic-service',
      check_command       => $check_command,
      service_description => $service_description,
      host_name           => $hostname }
  }
}
