class postfix::anonsasl {

  include postfix::header_checks

  postfix::config {
    'smtpd_sasl_authenticated_header':
      value => 'yes';
  }

  postfix::header_checks_snippet {
    'anonsasl':
      content => template("postfix/anonsasl_header_checks.erb"),
      require => [
                  Postfix::Config['smtpd_sasl_authenticated_header'],
                  ];
  }
  
}
