define site_nagios::add_host_services (
  $domain_full_suffix,
  $domain_internal,
  $ip_address,
  $services,
  $ssh_port,
  $environment,
  $openvpn_gateway_address='',
  ) {

    $nagios_hostname = $domain_internal

    # Add Nagios service

    # First, we need to turn the serice array into hash, using a "hash template"
    # see https://github.com/ashak/puppet-resource-looping
    $nagios_service_hashpart = {
      'hostname'    => $nagios_hostname,
      'ip_address'  => $ip_address,
      'openvpn_gw'  => $openvpn_gateway_address,
      'environment' => $environment
    }
    $dynamic_parameters = {
      'service' => '%s'
    }
    $nagios_servicename = "${nagios_hostname}_%s"

    $nagios_service_hash = create_resources_hash_from($nagios_servicename, $services, $nagios_service_hashpart, $dynamic_parameters)

    create_resources ( site_nagios::add_service, $nagios_service_hash )
}
