class shorewall::rules::http::disable inherits shorewall::rules::http {
  Shorewall::Rule['net-me-http-tcp']{
        action  => 'DROP',
    }
}
