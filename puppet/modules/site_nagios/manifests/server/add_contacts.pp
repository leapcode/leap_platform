define site_nagios::server::add_contacts ($contact_emails) {

  $environment = $name

  nagios_contact {
    $environment:
      alias                         => $environment,
      service_notification_period   => '24x7',
      host_notification_period      => '24x7',
      service_notification_options  => 'w,u,c,r',
      host_notification_options     => 'd,r',
      service_notification_commands => 'notify-service-by-email',
      host_notification_commands    => 'notify-host-by-email',
      email                         => join($contact_emails, ', ')
  }
}
