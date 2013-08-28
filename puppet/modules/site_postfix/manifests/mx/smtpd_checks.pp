class site_postfix::mx::smtpd_checks {

  postfix::config {
    'smtpd_client_restrictions':
      value => 'permit_mynetworks,permit';
    'smtpd_data_restrictions':
      value => 'permit_mynetworks, reject_unauth_pipelining, permit';
    'smtpd_delay_reject':
      value => 'yes';
    'smtpd_helo_restrictions':
      value => 'permit_mynetworks, reject_invalid_helo_hostname, reject_non_fqdn_helo_hostname, permit';
    'smtpd_recipient_restrictions':
      value => 'reject_unknown_recipient_domain, permit_mynetworks, check_recipient_access tcp:localhost:2244, reject_unauth_destination, permit';
    'smtpd_sender_restrictions':
      value => 'check_sender_access tcp:localhost:2244, permit_mynetworks, reject_non_fqdn_sender, reject_unknown_sender_domain, permit';
  }

}
