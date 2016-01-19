class site_postfix::mx::smtpd_checks {

  postfix::config {
    'smtpd_helo_required':
      value => 'yes';
    'checks_dir':
      value => '$config_directory/checks';
    'smtpd_client_restrictions':
      value => "permit_mynetworks,${site_postfix::mx::rbls},permit";
    'smtpd_data_restrictions':
      value => 'permit_mynetworks, reject_unauth_pipelining, permit';
    'smtpd_delay_reject':
      value => 'yes';
    'smtpd_helo_restrictions':
      value => 'permit_mynetworks, reject_invalid_helo_hostname, reject_non_fqdn_helo_hostname, check_helo_access hash:$checks_dir/helo_checks, permit';
    'smtpd_recipient_restrictions':
      value => 'reject_unknown_recipient_domain, permit_mynetworks, check_recipient_access tcp:localhost:2244, reject_unauth_destination, permit';

    # permit_tls_clientcerts will lookup client cert fingerprints from the tcp
    # lookup on port 2424 (based on what is configured in relay_clientcerts
    # paramter, see site_postfix::mx postfix::config resource) to determine
    # if a client is allowed to relay mail through us. This enables us to
    # disable a user by removing their valid client cert (#3634)
    'smtps_recipient_restrictions':
      value => 'permit_tls_clientcerts, check_recipient_access tcp:localhost:2244, reject_unauth_destination, permit';
    'smtps_helo_restrictions':
      value => 'permit_mynetworks, check_helo_access hash:$checks_dir/helo_checks, permit';
    'smtpd_sender_restrictions':
      value => 'permit_mynetworks, reject_non_fqdn_sender, reject_unknown_sender_domain, permit';
    }

}
