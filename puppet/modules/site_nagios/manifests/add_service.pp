define site_nagios::add_service (
  $hostname, $ip_address, $openvpn_gw = '', $service) {

  case $service {
    'webapp': {
      $check_command       = 'check_https_cert'
      $service_description = 'Website Certificate'
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
