define site_nagios::add_host {
  $nagios_host     = $name
  $nagios_hostname = $name['domain_full']
  $nagios_ip       = $name['ip_address']
  $nagios_services = $name['services']

  # Add Nagios host
  nagios_host { $nagios_hostname:
    address => $nagios_ip,
    use     => 'generic-host',
  }

  # Add Nagios service

  # First, we need to turn the serice array into hash, using a "hash template"
  # see https://github.com/ashak/puppet-resource-looping
  $nagios_service_hashpart = {
    'hostname'   => $nagios_hostname,
    'ip_address' => $nagios_ip,
  }
  $dynamic_parameters = {
    'service' => '%s'
  }
  $nagios_servicename = "${nagios_hostname}_%s"

  $nagios_service_hash = create_resources_hash_from($nagios_servicename, $nagios_services, $nagios_service_hashpart, $dynamic_parameters)

  create_resources ( site_nagios::add_service, $nagios_service_hash )
}
