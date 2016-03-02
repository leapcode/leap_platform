# create a nagios hostsgroup
define site_nagios::server::hostgroup ($contact_emails) {
  nagios_hostgroup { $name:
    ensure => present
  }
}
