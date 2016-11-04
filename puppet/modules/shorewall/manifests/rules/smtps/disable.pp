class shorewall::rules::smtps::disable inherits shorewall::rules::smtps {
  Shorewall::Rule['net-me-smtps-tcp']{
        action  => 'DROP',
    }
}
