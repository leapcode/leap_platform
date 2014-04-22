define site_nagios::add_service (
  $hostname, $ip_address, $openvpn_gw = '', $service) {

  case $service {
    'webapp': {
      nagios_service {
        "${name}_cert":
          use                 => 'generic-service',
          check_command       => 'check_https_cert',
          service_description => 'Website Certificate',
          host_name           => $hostname;
        "${name}_website":
          use                 => 'generic-service',
          check_command       => 'check_https',
          service_description => 'Website',
          host_name           => $hostname
      }
    }
    default:  {}
  }
}
