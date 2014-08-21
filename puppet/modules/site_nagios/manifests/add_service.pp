define site_nagios::add_service (
  $hostname, $ip_address, $openvpn_gw = '', $service) {

  $ssh      = hiera_hash('ssh')
  $ssh_port = $ssh['port']

  case $service {
    'webapp': {
      nagios_service {
        "${name}_ssh":
          use                 => 'generic-service',
          check_command       => "check_ssh_port!$ssh_port",
          service_description => 'SSH',
          host_name           => $hostname;
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
