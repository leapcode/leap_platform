class shorewall::rules::out::ssh::disable inherits shorewall::rules::out::ssh {
  Shorewall::Rule['me-net-tcp_ssh']{
    action => 'DROP',
  }
}
