# collect exported resources when using 'storeconfigs => true'
class nagios::storeconfigs {

  Nagios_command <<||>>
  Nagios_contactgroup <<||>>
  Nagios_contact <<||>>
  Nagios_hostdependency <<||>>
  Nagios_hostescalation <<||>>
  Nagios_hostextinfo <<||>>
  Nagios_hostgroup <<||>>
  Nagios_host <<||>>
  Nagios_servicedependency <<||>>
  Nagios_serviceescalation <<||>>
  Nagios_servicegroup <<||>>
  Nagios_serviceextinfo <<||>>
  Nagios_service <<||>>
  Nagios_timeperiod <<||>>

  Nagios_command <||> {
    notify  => Service['nagios'],
  }
  Nagios_contact <||> {
    notify  => Service['nagios'],
  }
  Nagios_contactgroup <||> {
    notify  => Service['nagios'],
  }
  Nagios_host <||> {
    notify  => Service['nagios'],
  }
  Nagios_hostdependency <||> {
    notify  => Service['nagios'],
  }
  Nagios_hostescalation <||> {
    notify  => Service['nagios'],
  }
  Nagios_hostextinfo <||> {
    notify  => Service['nagios'],
  }
  Nagios_hostgroup <||> {
    notify  => Service['nagios'],
  }
  Nagios_service <||> {
    notify  => Service['nagios'],
  }
  Nagios_servicegroup <||> {
    notify  => Service['nagios'],
  }
  Nagios_servicedependency <||> {
    notify  => Service['nagios'],
  }
  Nagios_serviceescalation <||> {
    notify  => Service['nagios'],
  }
  Nagios_serviceextinfo <||> {
    notify  => Service['nagios'],
  }
  Nagios_timeperiod <||> {
    notify  => Service['nagios'],
  }
}
