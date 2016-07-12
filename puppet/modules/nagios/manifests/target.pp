# a simple nagios target to monitor
class nagios::target(
  $parents      = 'absent',
  $address      = $::ipaddress,
  $nagios_alias = false,
  $hostgroups   = 'absent',
  $use          = 'generic-host',
){
  @@nagios_host { $::fqdn:
    address => $address,
    use     => $use,
  }
  # Watch out with using aliases: they need to be unique throughout *all*
  # resources in a given host's catalogue.
  if $nagios_alias {
    Nagios_host[$::fqdn]{
      alias => $nagios_alias
    }
  }

  if ($parents != 'absent') {
    Nagios_host[$::fqdn]{
      parents => $parents
    }
  }

  if ($hostgroups != 'absent') {
    Nagios_host[$::fqdn]{
      hostgroups => $hostgroups
    }
  }
}
