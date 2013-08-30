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
    # We should change from permit_tls_all_clientcerts to permit_tls_clientcerts
    # with a lookup on $relay_clientcerts! Right now we are listing the only
    # valid CA that client certificates can use in the $smtp_tls_CAfile parameter
    # but we cannot cut off a certificate that should no longer be used unless
    # we use permit_tls_clientcerts with the $relay_clientcerts lookup
    'smtps_recipient_restrictions':
      value => 'permit_tls_all_clientcerts, check_recipient_access tcp:localhost:2244, reject_unauth_destination, permit';
    'smtpd_sender_restrictions':
      value => 'permit_mynetworks, reject_non_fqdn_sender, reject_unknown_sender_domain, permit';
  }

}
