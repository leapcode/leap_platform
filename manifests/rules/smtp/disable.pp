class shorewall::rules::smtp::disable inherits shorewall::rules::smtp {
  Shorewall::Rule['net-me-smtp-tcp']{
    action          => 'DROP'
  }
}
