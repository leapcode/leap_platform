define site_nagios::add_host ($ip, $services='' ) {

  $nagios_hostname = $name

  #notice ("$nagios_hostname $ip $services")

  nagios_host { $nagios_hostname:
    address => $ip,
    use     => 'generic-host',
  }

  # turn serice array into hash
  # https://github.com/ashak/puppet-resource-looping
  $nagios_service_hashpart = {
    'host' => $nagios_hostname,
    'ip'   => $ip,
  }
  $dynamic_parameters = {
    'service' => '%s'
  }

  #$nagios_services = ['one', 'two']
  $nagios_servicename = "${nagios_hostname}_%s"

  $nagios_service_hash = create_resources_hash_from($nagios_servicename, $services, $nagios_service_hashpart, $dynamic_parameters)
  #notice ($created_resource_hash)


  create_resources ( site_nagios::add_service, $nagios_service_hash )
}
