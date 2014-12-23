define site_nagios::server::hostgroup ($contact_emails) {
  nagios_hostgroup { $name: }
}
