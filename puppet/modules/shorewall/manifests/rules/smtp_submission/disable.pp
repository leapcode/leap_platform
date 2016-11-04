class shorewall::rules::smtp_submission::disable inherits shorewall::rules::smtp_submission {
  Shorewall::Rule['net-me-smtp_submission-tcp']{
    action          => 'DROP'
  }
}
