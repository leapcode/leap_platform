class site_postfix::mx::smtpd_checks {

  postfix::config {
    'smtpd_data_restrictions':
      value => 'permit_mynetworks, reject_unauth_pipelining, permit'
  }

}
