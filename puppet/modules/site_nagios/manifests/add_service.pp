define site_nagios::add_service ($host, $ip, $service) {

  notice ('$name $host $ip $service')

  case $service {
    'openvpn': {
      $check_command       = 'check_openvpn!...'
      $service_description = 'Openvpn'
    }
    'webapp': {
      $check_command       = 'check_http!...'
      $service_description = 'Website'
    }
    default:  { fail ('unknown service') }
  }

  nagios_service { $name:
    use                 => 'generic-service',
    check_command       => $check_command,
    service_description => $service_description,
    host_name           => $host }
}
